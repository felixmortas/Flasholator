import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SubscriptionStatus {
  final bool isSubscribed;
  final bool canTranslate;

  SubscriptionStatus({required this.isSubscribed, required this.canTranslate});
}

class SubscriptionService {
  static final _firestore = FirebaseFirestore.instance;

  static Future<void> registerUser(String uid) async {
    final userDoc = _firestore.collection('users').doc(uid);
    final doc = await userDoc.get();

    if (!doc.exists) {
      await userDoc.set({
        'isSubscribed': false,
        'canTranslate': true,
        'subscriptionDate': null,
        'subscriptionEndDate': null,
      });
    }
  }

  static Future<void> banTranslation(String uid) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .update({'canTranslate': false});
  }

  static Future<void> subscribeUser(String uid) async {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(now);

    await _firestore.collection('users').doc(uid).update({
      'isSubscribed': true,
      'subscriptionDate': dateStr,
      'subscriptionEndDate': null,
      'canTranslate': true,
    });
  }

  static Future<void> scheduleSubscriptionRevocation({
    required String uid,
    required String? subscriptionDateStr,
  }) async {
    if (subscriptionDateStr == null) return;

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

    await _firestore.collection('users').doc(uid).update({
      'subscriptionEndDate': expirationStr,
    });
  }

  static Future<void> revokeSubscription({
    required String uid,
    required String? subscriptionEndDate,
  }) async {
    if (subscriptionEndDate == null) return;

    final now = DateTime.now();
    final endDate = DateTime.tryParse(subscriptionEndDate);
    if (endDate == null) return;

    if (now.isAfter(endDate)) {
      await _firestore.collection('users').doc(uid).update({
        'isSubscribed': false,
        'subscriptionEndDate': null,
      });
    }
  }

  static Future<void> deleteUser(String uid) async {
    await _firestore.collection('users').doc(uid).delete();
  }


  static Future<Map<String, dynamic>> handleUserStatus(
    String uid,
    Map<String, dynamic> userData,
  ) async {
    final now = DateTime.now();
    final endDateStr = userData['subscriptionEndDate'];
    final isSubscribed = userData['isSubscribed'] ?? false;

    if (endDateStr != null && isSubscribed) {
      final endDate = DateTime.tryParse(endDateStr);
      if (endDate != null && now.isAfter(endDate)) {
        await _firestore.collection('users').doc(uid).update({
          'isSubscribed': false,
          'subscriptionEndDate': null,
        });

        userData['isSubscribed'] = false;
        userData['subscriptionEndDate'] = null;
      }
    }

    return userData;
  }
}
