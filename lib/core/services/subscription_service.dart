// subscription_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'firestore_users_dao.dart';
import 'user_preferences_service.dart';
import 'local_user_data_notifier.dart';

class SubscriptionStatus {
  final bool isSubscribed;
  final bool canTranslate;

  SubscriptionStatus({required this.isSubscribed, required this.canTranslate});
}

class SubscriptionService {
  static final FirestoreUsersDAO _firestoreDAO = FirestoreUsersDAO();

  static Future<void> registerUser(String uid) async {
    final userData = {
      'isSubscribed': false,
      'canTranslate': true,
      'subscriptionDate': '',
      'subscriptionEndDate': '',
    };

    updateUser(uid, userData);
  }

  static Future<void> banTranslation(String uid) async {
    final updatedData = {'canTranslate': false};

    updateUser(uid, updatedData);
  }

  static Future<void> subscribeUser(String uid) async {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(now);

    final updatedData = {
      'isSubscribed': true,
      'subscriptionDate': dateStr,
      'subscriptionEndDate': '',
      'canTranslate': true,
    };

    updateUser(uid, updatedData);
  }

  static Future<void> scheduleSubscriptionRevocation({
    required String uid,
  }) async {
    final userData = LocalUserDataNotifier.userDataNotifier.value;
    final subscriptionDateStr = userData['subscriptionDate'] as String?;
    if (subscriptionDateStr == null || subscriptionDateStr.isEmpty) return;

    final subscriptionDate = DateTime.tryParse(subscriptionDateStr);
    if (subscriptionDate == null) return;

    final now = DateTime.now();
    final int targetDay = subscriptionDate.day;

    DateTime expirationDate;

    if (now.day <= targetDay) {
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

    updateUser(uid, updatedData);
  }

  static Future<void> revokeSubscription({
    required String uid,
  }) async {
    final userData = LocalUserDataNotifier.userDataNotifier.value;
    final subscriptionEndDate = userData['subscriptionEndDate'] as String?;
    if (subscriptionEndDate == null || subscriptionEndDate.isEmpty) return;

    final now = DateTime.now();
    final endDate = DateTime.tryParse(subscriptionEndDate);
    if (endDate == null) return;

    if (now.isAfter(endDate)) {
      final updatedData = {
        'isSubscribed': false,
        'subscriptionDate': '',
        'subscriptionEndDate': '',
      };

      updateUser(uid, updatedData);
    }
  }

  static Future<void> deleteUser(String uid) async {
    await _firestoreDAO.deleteUser(uid);
    await UserPreferencesService.deleteUser();
    LocalUserDataNotifier.clearUserData();
  }

  static Future<void> checkSubscriptionStatus(
    String uid,
  ) async {
    final userData = LocalUserDataNotifier.userDataNotifier.value;

    final now = DateTime.now();
    final endDateStr = userData['subscriptionEndDate'];
    final isSubscribed = userData['isSubscribed'] ?? false;

    if (endDateStr != '' && isSubscribed) {
      final endDate = DateTime.tryParse(endDateStr);
      if (endDate != null && now.isAfter(endDate)) {
        await revokeSubscription(uid: uid);
      }
    }
  }

  static Future<Map<String, dynamic>> getUserFromNotifier(String uid) async {
    final userDoc = LocalUserDataNotifier.userDataNotifier.value;
    if (userDoc.isEmpty) {
      await syncUser(uid); // assure que c'est bien rempli
    }
    return LocalUserDataNotifier.userDataNotifier.value;
  }


  static Future<DocumentSnapshot<Map<String, dynamic>>> getUserFromFirestore(String uid) async {
    final userDoc = await _firestoreDAO.getUser(uid);
    return userDoc;
  }

  static Future<void> syncUser (String uid) async {
    final userDoc = await _firestoreDAO.getUser(uid);
    if (!userDoc.exists) {
      await registerUser(uid);
      return;
    }

    final userData = userDoc.data() as Map<String, dynamic>;
    await UserPreferencesService.updateUser(userData);
    LocalUserDataNotifier.updateUser(userData);
  }
  
  // Nouvelle méthode pour mettre à jour dynamiquement les données utilisateur
  static Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _firestoreDAO.updateUser(uid, data);
    await UserPreferencesService.updateUser(data);
    LocalUserDataNotifier.updateUser(data);
  }

  static Future<bool> isUserDataCached() async {
    return UserPreferencesService.isUserDataCached();
  }

  static ValueNotifier<Map<String, dynamic>> userDataNotifier() {
    return LocalUserDataNotifier.userDataNotifier;
  }
}