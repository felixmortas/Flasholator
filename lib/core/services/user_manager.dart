import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import 'package:flasholator/core/providers/free_plan_limits_provider.dart';
import 'package:flasholator/core/services/auth_service.dart';
import 'package:flasholator/core/services/firestore_users_dao.dart';
import 'package:flasholator/core/services/user_preferences_service.dart';
import 'package:flasholator/core/services/revenuecat_service.dart';
import 'package:flasholator/core/providers/user_data_provider.dart';

enum SubscriptionActionResult {
  activated,
  deactivated,
  unchanged,
  cancelled,
  pending,
  failed,
  ignored,
}

class UserManager {
  final FirestoreUsersDAO _firestoreDAO;
  final AuthService _authService;
  final RevenueCatService _revenueCatService;
  final Ref ref;
  Future<void> _counterMutation = Future<void>.value();
  String? _sessionUid;
  bool _sessionBound = false;
  int _sessionGeneration = 0;
  int _subscriptionOperation = 0;

  /// Invalide immédiatement les opérations anciennes, avant toute attente.
  void beginSession(String? uid, int generation) {
    _sessionUid = uid;
    _sessionBound = true;
    _sessionGeneration = generation;
    _subscriptionOperation++;
  }

  bool _isCurrent(String uid, int generation) =>
      _sessionUid == uid && _sessionGeneration == generation &&
      _authService.getUserId() == uid;

  bool Function() _guard(String uid, int generation) =>
      () => _isCurrent(uid, generation);

  Future<void> clearSessionData(int generation) async {
    if (generation != _sessionGeneration) return;
    final owner = await UserPreferencesService.getCacheOwnerUid();
    if (generation != _sessionGeneration) return;
    if (_sessionUid == null || owner != _sessionUid) {
      await UserPreferencesService.clearUserData();
    }
    if (generation == _sessionGeneration) userNotifier.clear();
  }

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
    final uid = getUserId();
    final generation = _sessionGeneration;
    if (!await tryUseLanguagePair(sourceLang, targetLang, persist: false,
        isCurrent: () => !_sessionBound || _isCurrent(uid, generation))) {
      throw StateError('Limite de couples de langues atteinte');
    }
    if (_sessionBound && !_isCurrent(uid, generation)) return;
    final data = {'coupleLang': '$sourceLang-$targetLang'};

    await updateUser(data);
    if (_isCurrent(uid, generation)) {
      await tryUseLanguagePair(sourceLang, targetLang);
    }
  }

  Future<bool> tryUseLanguagePair(String sourceLang, String targetLang, {
    bool persist = true,
    bool Function()? isCurrent,
  }) async {
    if (ref.read(isSubscribedProvider)) return true;
    final sessionUserId = getUserId();
    final generation = _sessionGeneration;
    String canonicalPair(String first, String second) =>
        first.compareTo(second) <= 0 ? '$first-$second' : '$second-$first';
    final pair = canonicalPair(sourceLang, targetLang);
    final stored = (await UserPreferencesService.getUsedLanguagePairs(
        uid: _sessionBound ? sessionUserId : null))
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
    if (( _sessionBound && !_isCurrent(sessionUserId, generation)) ||
        getUserId() != sessionUserId ||
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
      await UserPreferencesService.setUsedLanguagePairs(used.toList(),
          uid: _sessionBound ? sessionUserId : null,
          isCurrent: !_sessionBound ? isCurrent : () =>
              _isCurrent(sessionUserId, generation) &&
              (isCurrent == null || isCurrent()));
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
    final generation = _sessionGeneration;
    final currentCounter = await UserPreferencesService.getCounter();
    if ((_sessionBound && !_isCurrent(sessionUserId, generation)) ||
        getUserId() != sessionUserId || (isCurrent != null && !isCurrent())) {
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
    await updateLocal({'counter': updatedCounter},
        isCurrent: () => (!_sessionBound || _isCurrent(sessionUserId, generation)) &&
            (isCurrent == null || isCurrent()));
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

  Future<SubscriptionActionResult> subscribeUser() async {
    final userId = getUserId();
    final generation = _sessionGeneration;
    final operation = ++_subscriptionOperation;
    final outcome = await _revenueCatService.presentPaywall(userId);
    if (!_isSubscriptionOperationCurrent(userId, generation, operation)) {
      return SubscriptionActionResult.ignored;
    }
    if (outcome == PaywallResult.notPresented) {
      return SubscriptionActionResult.pending;
    }
    if (outcome == PaywallResult.error) {
      return SubscriptionActionResult.failed;
    }
    final result = await _reconcileSubscription(userId, generation, operation);
    return outcome == PaywallResult.cancelled &&
            result == SubscriptionActionResult.unchanged
        ? SubscriptionActionResult.cancelled
        : result;
  }

  Future<SubscriptionActionResult> restorePurchases() async {
    final userId = getUserId();
    final generation = _sessionGeneration;
    final operation = ++_subscriptionOperation;
    final confirmed = await _revenueCatService.restorePurchases();
    if (!_isSubscriptionOperationCurrent(userId, generation, operation)) {
      return SubscriptionActionResult.ignored;
    }
    return _applySubscription(userId, generation, operation, confirmed);
  }

  /// Relit RevenueCat après le retour d'un paywall externe ou au premier plan.
  Future<SubscriptionActionResult> refreshSubscription() async {
    final userId = getUserId();
    final generation = _sessionGeneration;
    final operation = ++_subscriptionOperation;
    return _reconcileSubscription(userId, generation, operation);
  }

  bool _isSubscriptionOperationCurrent(
          String userId, int generation, int operation) =>
      operation == _subscriptionOperation &&
      _authService.getUserId() == userId &&
      (!_sessionBound || _isCurrent(userId, generation));

  Future<SubscriptionActionResult> _reconcileSubscription(
      String userId, int generation, int operation) async {
    final confirmed = await isUserSubscribed();
    return _applySubscription(userId, generation, operation, confirmed);
  }

  Future<SubscriptionActionResult> _applySubscription(
      String userId, int generation, int operation, bool confirmed) async {
    if (!_isSubscriptionOperationCurrent(userId, generation, operation)) {
      return SubscriptionActionResult.ignored;
    }
    final previous = userNotifier.isSubscribed;
    await updateLocal({'isSubscribed': confirmed},
        isCurrent: () => _isSubscriptionOperationCurrent(
            userId, generation, operation));
    if (!_isSubscriptionOperationCurrent(userId, generation, operation)) {
      return SubscriptionActionResult.ignored;
    }
    if (confirmed == previous) return SubscriptionActionResult.unchanged;
    return confirmed
        ? SubscriptionActionResult.activated
        : SubscriptionActionResult.deactivated;
  }

  Future<void> signOut() async {
    final generation = _sessionGeneration;
    try {
      await _revenueCatService.logOut();
    } finally {
      await _authService.signOut();
      if (generation == _sessionGeneration) await clearLocalData();
    }
  }

  Future<void> clearLocalData() async {
    final generation = _sessionGeneration;
    await UserPreferencesService.clearUserData();
    if (generation == _sessionGeneration) userNotifier.clear();
  }

  Future<void> deleteUser() async {
    final uid = _authService.getUserId();
    final generation = _sessionGeneration;
    if (uid.isNotEmpty) {
      await _authService.deleteUser();
      await _firestoreDAO.deleteUser(uid);
      try {
        await _revenueCatService.logOut();
      } finally {
        if (generation == _sessionGeneration) {
          await UserPreferencesService.deleteUser(uid: uid);
          if (generation == _sessionGeneration) userNotifier.clear();
        }
      }
    }
  }

  Future<void> syncNotifierFromCache() async {
    final uid = getUserId();
    final generation = _sessionGeneration;
    final data = await UserPreferencesService.loadUserData();
    data['isSubscribed'] = await isUserSubscribed();
    if (!_sessionBound || _isCurrent(uid, generation)) {
      userNotifier.update(data);
    }
  }

  Future<void> syncLocalFromFirestore() async {
    final uid = getUserId();
    final generation = _sessionGeneration;
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

    await updateLocal(data, isCurrent: _guard(uid, generation));
  }

  Future<void> updateLocal(Map<String, dynamic> data,
      {bool Function()? isCurrent}) async {
    final uid = getUserId();
    final generation = _sessionGeneration;
    bool current() => (isCurrent == null || isCurrent()) &&
        (!_sessionBound || _isCurrent(uid, generation));
    await UserPreferencesService.updateUser(data,
        uid: _sessionBound ? uid : null, isCurrent: current);
    if (current()) userNotifier.update(data);
  }

  Future<void> updateUser(Map<String, dynamic> data) async {
    final uid = _authService.getUserId();
    final generation = _sessionGeneration;

    await _firestoreDAO.updateUser(uid, data);
    if (_sessionBound && !_isCurrent(uid, generation)) return;
    await updateLocal(data, isCurrent: () =>
        !_sessionBound || _isCurrent(uid, generation));
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
