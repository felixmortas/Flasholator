import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flasholator/core/providers/free_plan_limits_provider.dart';
import 'package:flasholator/core/services/auth_service.dart';
import 'package:flasholator/core/services/firestore_users_dao.dart';
import 'package:flasholator/core/services/user_preferences_service.dart';
import 'package:flasholator/core/services/revenuecat_service.dart';
import 'package:flasholator/core/providers/user_data_provider.dart';

class UserManager {
  final FirestoreUsersDAO _firestoreDAO;
  final AuthService _authService;
  final RevenueCatService _revenueCatService;
  final Ref ref;
  Future<void> _counterMutation = Future<void>.value();

  UserManager(
      {required this.ref,
      required FirestoreUsersDAO firestoreDAO,
      required AuthService authService,
      required RevenueCatService revenueCatService})
      : _firestoreDAO = firestoreDAO,
        _authService = authService,
        _revenueCatService = revenueCatService;

  UserDataNotifier get userNotifier => ref.read(userDataProvider.notifier);

  Future<void> initRevenueCat() async {
    final uid = getUserId();
    await _revenueCatService.initRevenueCat(uid);
  }

  Future<void> setCoupleLang(String sourceLang, String targetLang) async {
    if (!await tryUseLanguagePair(sourceLang, targetLang, persist: false)) {
      throw StateError('Limite de couples de langues atteinte');
    }
    final data = {'coupleLang': '$sourceLang-$targetLang'};

    await updateUser(data);
    await tryUseLanguagePair(sourceLang, targetLang);
  }

  Future<bool> tryUseLanguagePair(String sourceLang, String targetLang, {
    bool persist = true,
    bool Function()? isCurrent,
  }) async {
    if (ref.read(isSubscribedProvider)) return true;
    final sessionUserId = getUserId();
    String canonicalPair(String first, String second) =>
        first.compareTo(second) <= 0 ? '$first-$second' : '$second-$first';
    final pair = canonicalPair(sourceLang, targetLang);
    final stored = (await UserPreferencesService.getUsedLanguagePairs())
        .map((entry) {
          final languages = entry.split('-');
          return languages.length == 2
              ? canonicalPair(languages[0], languages[1])
              : entry;
        })
        .toSet();
    final used = {...stored};
    final currentPair = ref.read(coupleLangProvider);
    final currentLanguages = currentPair.split('-');
    if (currentLanguages.length == 2) {
      used.add(canonicalPair(currentLanguages[0], currentLanguages[1]));
    }
    if (getUserId() != sessionUserId ||
        (isCurrent != null && !isCurrent())) {
      return false;
    }
    if (!ref.read(freePlanLimitsProvider).canUseLanguagePair(
      usedPairCount: used.length,
      alreadyUsed: used.contains(pair),
      isPremium: false,
    )) {
      return false;
    }
    if (persist && !stored.contains(pair)) {
      used.add(pair);
      await UserPreferencesService.setUsedLanguagePairs(used.toList());
    }
    return true;
  }

  Future<void> banTranslation(BuildContext context) async {
    final data = {'canTranslate': false};

    await updateUser(data);
  }

  Future<void> incrementCounter({
    bool Function()? isCurrent,
  }) {
    final mutation = _counterMutation.then(
      (_) => _incrementCounter(isCurrent: isCurrent),
    );
    _counterMutation = mutation.catchError((Object _) {});
    return mutation;
  }

  Future<void> _incrementCounter({bool Function()? isCurrent}) async {
    final sessionUserId = getUserId();
    final currentCounter = await UserPreferencesService.getCounter();
    if (getUserId() != sessionUserId || (isCurrent != null && !isCurrent())) {
      return;
    }
    if (ref.read(isSubscribedProvider)) {
      return;
    }
    final updatedCounter = currentCounter + 1;

    // Le compteur reste la source du quota : un ancien booléen persistant ne
    // doit pas bloquer une limite relevée ou désactivée par configuration.
    if (!ref.read(freePlanLimitsProvider).canTranslate(
      count: currentCounter,
      isPremium: false,
    )) {
      return;
    }
    await updateLocal({'counter': updatedCounter});
  }

  Future<void> reauthenticateWithCredential(String password) async {
    await _authService.reauthenticateWithCredential(password);
  }

  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    await _authService.changePassword(currentPassword, newPassword);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }

  Future<bool> isEmailVerified() async {
    await _authService.reloadUser();
    return await _authService.isEmailVerified();
  }

  Future<void> sendEmailVerification() async {
    await _authService.sendEmailVerification();
  }

  Stream<User?> authStateChanges() {
    return _authService.authStateChanges();
  }

  Future<void> registerUser(
      String email, String password, String username) async {
    await _authService.registerUser(email, password);
    await _authService.updateDisplayName(username);
    await _authService.sendEmailVerification();
  }

  Future<void> login(String email, String password) async {
    await _authService.login(email, password);
  }

  Future<void> subscribeUser() async {
    final bool wasSubscribed = userNotifier.isSubscribed;
    final userId = getUserId();
    await _revenueCatService.presentPaywall(userId);
    if (!wasSubscribed) {
      final bool isSubscribed = await isUserSubscribed();
      if (isSubscribed) {
        updateLocal({"isSubscribed": isSubscribed});
      }
    }
  }

  Future<void> signOut() async {
    try {
      await _revenueCatService.logOut();
    } finally {
      await _authService.signOut();
      await clearLocalData();
    }
  }

  Future<void> clearLocalData() async {
    await UserPreferencesService.clearUserData();
    userNotifier.clear();
  }

  Future<void> deleteUser() async {
    final uid = _authService.getUserId();
    if (uid.isNotEmpty) {
      await _authService.deleteUser();
      await _firestoreDAO.deleteUser(uid);
      try {
        await _revenueCatService.logOut();
      } finally {
        await UserPreferencesService.deleteUser();
        userNotifier.clear();
      }
    }
  }

  Future<void> syncNotifierFromCache() async {
    final data = await UserPreferencesService.loadUserData();
    userNotifier.update(data..['isSubscribed'] = await isUserSubscribed());
  }

  Future<void> syncLocalFromFirestore() async {
    final userDoc = await getUserFromFirestore();
    final userDocData = userDoc.data() as Map<String, dynamic>;
    final bool canTranslate = userDocData['canTranslate'] ?? false;
    final String coupleLang = userDocData['coupleLang'] ?? '';
    final bool isSubscribed = await isUserSubscribed();

    final data = {
      'canTranslate': canTranslate,
      'coupleLang': coupleLang,
      'isSubscribed': isSubscribed,
    };

    await updateLocal(data);
  }

  Future<void> updateLocal(Map<String, dynamic> data) async {
    await UserPreferencesService.updateUser(data);
    userNotifier.update(data);
  }

  Future<void> updateUser(Map<String, dynamic> data) async {
    final uid = _authService.getUserId();

    await _firestoreDAO.updateUser(uid, data);
    await UserPreferencesService.updateUser(data);
    userNotifier.update(data);
  }

  Future<bool> isUserDataCached() async {
    return UserPreferencesService.isUserDataCached();
  }

  Future<bool> isUserSubscribed() async {
    final isSubscribed = await _revenueCatService.isSubscribed();
    return isSubscribed;
  }

  Future<Map<String, dynamic>> getUserFromUserPrefs() async {
    return await UserPreferencesService.loadUserData();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserFromFirestore() async {
    final uid = getUserId();
    final userDoc = await _firestoreDAO.getUser(uid);
    return userDoc;
  }

  String getUserEmail() {
    return _authService.getUserEmail();
  }

  String getUserName() {
    return _authService.getUserName();
  }

  String getUserId() {
    return _authService.getUserId();
  }

  DateTime getSignupDate() {
    return _authService.getSignupDate();
  }
}
