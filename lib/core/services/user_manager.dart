import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flasholator/config/constants.dart';
import 'package:flasholator/core/services/auth_service.dart';
import 'package:flasholator/core/services/firestore_users_dao.dart';
import 'package:flasholator/core/services/user_preferences_service.dart';
import 'package:flasholator/core/services/revenuecat_service.dart';
import 'package:flasholator/core/providers/user_data_provider.dart';
import 'package:flasholator/core/providers/user_sync_provider.dart';

class UserManager {
  final FirestoreUsersDAO _firestoreDAO;
  final AuthService _authService;
  final RevenueCatService _revenueCatService;
  final Ref ref;

  UserManager({required this.ref, required FirestoreUsersDAO firestoreDAO, required AuthService authService, required RevenueCatService revenueCatService})
      : _firestoreDAO = firestoreDAO,
        _authService = authService,
        _revenueCatService = revenueCatService;


  UserDataNotifier get userNotifier => ref.read(userDataProvider.notifier);

  Future<void> setCoupleLang(String sourceLang, String targetLang) async {
    final data = {'coupleLang': '$sourceLang-$targetLang'};

    await updateUser(data);
  }

  Future<void> banTranslation(BuildContext context) async {
    final data = {'canTranslate': false};

    await updateUser(data);
  }

  Future<void> incrementCounter(BuildContext context) async {
    final currentCounter = await UserPreferencesService.getCounter();
    final updatedCounter = currentCounter + 1;

    updateLocal({'counter': updatedCounter});

    // Si limite atteinte, bloquer les traductions
    if (updatedCounter >= MAX_TRANSLATIONS) {
      await banTranslation(context);
    }
  }

  Future<void> reauthenticateWithCredential(String password) async {
    await _authService.reauthenticateWithCredential(password);
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
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

  Future<void> registerUser(String email, String password, String username) async {
    await _authService.registerUser(email, password);
    await _authService.updateDisplayName(username);
    await _authService.sendEmailVerification();
  }

  Future<void> login(String email, String password) async {
    try {
      await _authService.login(email, password);
      await syncUser();

    } catch (e) {
      throw Exception('Failed to login and sync user: $e');
    }
  }

  Future<void> subscribeUser() async {
    final bool wasSubscribed = userNotifier.isSubscribed;
    await _revenueCatService.presentPaywall();
    if(!wasSubscribed) {
      final bool isSubscribed = await _revenueCatService.isSubscribed();
      if (isSubscribed) {
        updateLocal({"isSubscribed": isSubscribed});
      }
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<void> deleteUser() async {
    final uid = _authService.getUserId();
    if (uid != null) {
      await _authService.deleteUser();
      await _firestoreDAO.deleteUser(uid);
      await UserPreferencesService.deleteUser();
      userNotifier.clear();
    }
  }

  Future<void> syncNotifier() async {
    final data = await UserPreferencesService.loadUserData();
    userNotifier.update(data..['isSubscribed'] = await _revenueCatService.isSubscribed());
  }

  Future<void> syncUser() async {
    final userDoc = await getUserFromFirestore();
    final userDocData = userDoc.data() as Map<String, dynamic>;
    final bool canTranslate = userDocData['canTranslate'] ?? false;
    final String coupleLang = userDocData['coupleLang'] ?? '';
    final bool isSubscribed = await _revenueCatService.isSubscribed();

    final data = {
      'canTranslate': canTranslate,
      'coupleLang': coupleLang,
      'isSubscribed': isSubscribed,
    };

    updateLocal(data);

    ref.read(userSyncStateProvider.notifier).state = true;
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

  Future<bool> isSubscribed() async {
    final isSubscribed = await _revenueCatService.isSubscribed();
    return isSubscribed;
  }

  Future<Map<String, dynamic>> getUserFromUserPrefs() async {
    return await UserPreferencesService.loadUserData();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserFromFirestore() async {
    final uid = _authService.getUserId();
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

}