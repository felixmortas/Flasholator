import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flasholator/core/services/firestore_users_dao.dart';
import 'package:flasholator/core/services/user_preferences_service.dart';
import 'package:flasholator/core/providers/user_data_provider.dart';

class SubscriptionService {
  static final FirestoreUsersDAO _firestoreDAO = FirestoreUsersDAO();
  final Ref ref;

  SubscriptionService(this.ref);

  UserDataNotifier get userNotifier => ref.read(userDataProvider.notifier);

  Future<void> registerUser(String uid) async {
    final userData = {
      'isSubscribed': false,
      'canTranslate': true,
      'subscriptionDate': '',
      'subscriptionEndDate': '',
    };

    updateUser(uid, userData);
  }

  Future<void> banTranslation(String uid) async {
    final updatedData = {'canTranslate': false};

    updateUser(uid, updatedData);
  }

  Future<void> subscribeUser(String uid) async {
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

  Future<void> scheduleSubscriptionRevocation({
    required String uid,
  }) async {
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

    updateUser(uid, updatedData);
  }

  Future<void> revokeSubscription({
    required String uid,
  }) async {
    final subscriptionEndDate = userNotifier.subscriptionEndDate;
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

      updateUser(uid, updatedData);
    }
  }

  Future<void> deleteUser(String uid) async {
    await _firestoreDAO.deleteUser(uid);
    await UserPreferencesService.deleteUser();
    userNotifier.clear();

  }

  Future<void> checkSubscriptionStatus(
    String uid,
  ) async {
    await getUserFromNotifier(uid); // assure le cache
    final now = DateTime.now();

    if (userNotifier.subscriptionEndDate != '' &&
        userNotifier.isSubscribed) {
      final endDate = DateTime.tryParse(userNotifier.subscriptionEndDate);
      if (endDate != null && now.isAfter(endDate)) {
        await revokeSubscription(uid: uid);
      }
    }
  }

  Future<Map<String, dynamic>> getUserFromNotifier(String uid) async {
    if (userNotifier.current.isEmpty) {
      await syncUser(uid); // assure que c'est bien rempli
    }
    return userNotifier.current;
  }


  Future<DocumentSnapshot<Map<String, dynamic>>> getUserFromFirestore(String uid) async {
    final userDoc = await _firestoreDAO.getUser(uid);
    return userDoc;
  }

  Future<void> syncUser (String uid) async {
    final userDoc = await _firestoreDAO.getUser(uid);
    if (!userDoc.exists) {
      await registerUser(uid);
      return;
    }

    final data = userDoc.data() as Map<String, dynamic>;
    await UserPreferencesService.updateUser(data);
    userNotifier.update(data);
  }
  
  // Nouvelle méthode pour mettre à jour dynamiquement les données utilisateur
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _firestoreDAO.updateUser(uid, data);
    await UserPreferencesService.updateUser(data);
    userNotifier.update(data);
  }

  Future<bool> isUserDataCached() async {
    return UserPreferencesService.isUserDataCached();
  }
}