import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flasholator/core/services/firestore_users_dao.dart';
import 'package:flasholator/core/services/user_preferences_service.dart';
import 'package:flasholator/core/providers/user_data_provider.dart';
import 'package:flasholator/core/providers/user_sync_provider.dart';

class UserManager {
  final FirestoreUsersDAO _firestoreDAO;
  final FirebaseAuth _firebaseAuth;
  final Ref ref;

  UserManager({required this.ref, required FirestoreUsersDAO firestoreDAO, required FirebaseAuth firebaseAuth})
      : _firestoreDAO = firestoreDAO,
        _firebaseAuth = firebaseAuth;


  UserDataNotifier get userNotifier => ref.read(userDataProvider.notifier);

  Future<void> banTranslation(BuildContext context) async {
    final updatedData = {'canTranslate': false};

    updateUser(updatedData);
  }

  Future<void> incrementCounter(BuildContext context) async {
    final currentCounter = await UserPreferencesService.getCounter();
    final updatedCounter = currentCounter + 1;

    // Mettre à jour les préférences
    await UserPreferencesService.updateUser({'counter': updatedCounter});
    // Mettre à jour le provider
    userNotifier.update({'counter': updatedCounter});

    // Si limite atteinte, bloquer les traductions
    if (updatedCounter >= 100) {
      if (!context.mounted) return;
      await banTranslation(context);
    }
  }

  Future<void> registerUser() async {
    final userData = {
      'isSubscribed': false,
      'canTranslate': true,
      'subscriptionDate': '',
      'subscriptionEndDate': '',
    };

    updateUser(userData);
  }

  Future<void> subscribeUser() async {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(now);

    final updatedData = {
      'isSubscribed': true,
      'subscriptionDate': dateStr,
      'subscriptionEndDate': '',
    };

    updateUser(updatedData);
  }

  Future<void> scheduleSubscriptionRevocation() async {
    final subscriptionDateStr = userNotifier.subscriptionDate;

    if (subscriptionDateStr.isEmpty) return;

    final subscriptionDate = DateTime.tryParse(subscriptionDateStr);
    if (subscriptionDate == null) return;

    final now = DateTime.now();
    final int targetDay = subscriptionDate.day;

    DateTime expirationDate;

    if (now.day < targetDay) {
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      final safeDay = targetDay > daysInMonth ? daysInMonth : targetDay;
      expirationDate = DateTime(now.year, now.month, safeDay);
    } else {
      final nextMonth = now.month == 12 ? 1 : now.month + 1;
      final nextYear = now.month == 12 ? now.year + 1 : now.year;
      final daysInNextMonth = DateTime(nextYear, nextMonth + 1, 0).day;
      final safeDay = targetDay > daysInNextMonth ? daysInNextMonth : targetDay;
      expirationDate = DateTime(nextYear, nextMonth, safeDay);
    }

    final expirationStr = DateFormat('yyyy-MM-dd').format(expirationDate);

    final updatedData = {
      'subscriptionEndDate': expirationStr,
    };

    updateUser(updatedData);
  }

  Future<void> revokeSubscription(String subscriptionEndDate) async {
    if (subscriptionEndDate.isEmpty) return;

    final now = DateTime.now();
    final endDate = DateTime.tryParse(subscriptionEndDate);
    if (endDate == null) return;

    if (now.isAfter(endDate)) {
      final updatedData = {
        'isSubscribed': false,
        'subscriptionDate': '',
        'subscriptionEndDate': '',
      };

      updateUser(updatedData);
    }
  }

  Future<void> deleteUser() async {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid != null) {
      await _firestoreDAO.deleteUser(uid);
      await UserPreferencesService.deleteUser();
      userNotifier.clear();
    }
  }

  Future<void> checkSubscriptionStatus(
  ) async {
    final data = await getUserFromUserPrefs(); // assure le cache
    final now = DateTime.now();
    final subscriptionEndDate = data['subscriptionEndDate'];
    final isSubscribed = data['isSubscribed'];

    if (subscriptionEndDate != '' &&
        isSubscribed) {
      final endDate = DateTime.tryParse(subscriptionEndDate);
      if (endDate != null && now.isAfter(endDate)) {
        await revokeSubscription(subscriptionEndDate);
      }
    }
  }

  Future<Map<String, dynamic>> getUserFromUserPrefs() async {
    return await UserPreferencesService.loadUserData();
  }

  Future<Map<String, dynamic>> getUserFromNotifier() async {
    if (userNotifier.current.isEmpty) {
      final data = await UserPreferencesService.loadUserData();
      userNotifier.update(data);
    }
    return userNotifier.current;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserFromFirestore() async {
    final uid = _firebaseAuth.currentUser!.uid;
    
    final userDoc = await _firestoreDAO.getUser(uid);
    return userDoc;
  }

  Future<void> syncUser() async {
    final uid = _firebaseAuth.currentUser!.uid;
    final userDoc = await _firestoreDAO.getUser(uid);
    final data = userDoc.data() as Map<String, dynamic>;

    await UserPreferencesService.updateUser(data);
    userNotifier.update(data);

    ref.read(userSyncStateProvider.notifier).state = true;
  }

  Future<void> loginAndSyncUser(String email, String password) async {
    try {
      
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      await syncUser();

    } catch (e) {
      throw Exception('Failed to login and sync user: $e');
    }
  }

  
  Future<void> updateUserNotifier(Map<String, dynamic> data) async {
    userNotifier.update(data);
  }

  // Nouvelle méthode pour mettre à jour dynamiquement les données utilisateur
  Future<void> updateUser(Map<String, dynamic> data) async {
    final uid = _firebaseAuth.currentUser!.uid;

    await _firestoreDAO.updateUser(uid, data);
    await UserPreferencesService.updateUser(data);
    userNotifier.update(data);
  }

  Future<bool> isUserDataCached() async {
    return UserPreferencesService.isUserDataCached();
  }
}