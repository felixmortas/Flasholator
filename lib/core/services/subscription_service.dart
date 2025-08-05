// subscription_service.dart
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
    await _firestoreDAO.registerUser(uid);
    
    // Charger les données utilisateur et mettre à jour le notifier
    final userData = await UserPreferencesService.loadUserData();
    LocalUserDataNotifier.updateUserData(userData);
  }

  static Future<void> banTranslation(String uid) async {
    await _firestoreDAO.banTranslation(uid);
    
    // Mettre à jour localement
    await UserPreferencesService.banTranslation();
    
    // Mettre à jour le notifier
    LocalUserDataNotifier.updateUserData({'canTranslate': false});
  }

  static Future<void> subscribeUser(String uid) async {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(now);

    await _firestoreDAO.subscribeUser(uid, dateStr);
    
    // Mettre à jour localement
    await UserPreferencesService.subscribeUser(dateStr);
    
    // Mettre à jour le notifier
    LocalUserDataNotifier.updateUserData({
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

    await _firestoreDAO.scheduleSubscriptionRevocation(
      uid: uid,
      expirationStr: expirationStr,
    );
    
    // Mettre à jour localement
    await UserPreferencesService.scheduleSubscriptionRevocation(expirationStr);
    
    // Mettre à jour le notifier
    LocalUserDataNotifier.updateUserData({
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
      await _firestoreDAO.revokeSubscription(uid);
      
      // Mettre à jour localement
      await UserPreferencesService.revokeSubscription();
      
      // Mettre à jour le notifier
      LocalUserDataNotifier.updateUserData({
        'isSubscribed': false,
        'subscriptionEndDate': null,
      });
    }
  }

  static Future<void> deleteUser(String uid) async {
    await _firestoreDAO.deleteUser(uid);
    
    // Supprimer localement
    await UserPreferencesService.deleteUser();
    
    // Mettre à jour le notifier
    LocalUserDataNotifier.clearUserData();
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
        await _firestoreDAO.revokeSubscription(uid);

        userData['isSubscribed'] = false;
        userData['subscriptionEndDate'] = null;
        
        // Mettre à jour localement
        await UserPreferencesService.revokeSubscription();
        
        // Mettre à jour le notifier
        LocalUserDataNotifier.updateUserData({
          'isSubscribed': false,
          'subscriptionEndDate': null,
        });
      }
    }

    return userData;
  }

  // Méthodes utilitaires pour la gestion locale
  static Future<void> saveUserFieldsLocally(Map<String, dynamic> fields) async {
    await UserPreferencesService.saveUserFieldsLocally(fields);
    
    // Mettre à jour le notifier avec les champs modifiés
    LocalUserDataNotifier.updateUserData(fields);
  }

  static Future<void> loadUserData() async {
    final userData = await UserPreferencesService.loadUserData();
    
    // Mettre à jour le notifier
    LocalUserDataNotifier.updateUserData(userData);
  }

  static Future<bool> isUserDataCached() async {
    return await UserPreferencesService.isUserDataCached();
  }

  static Map<String, dynamic> getCurrentUserData() {
    return LocalUserDataNotifier.userDataNotifier.value;
  }
  
  // Nouvelle méthode pour mettre à jour dynamiquement les données utilisateur
  static Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _firestoreDAO.updateUser(uid, data);
    await UserPreferencesService.updateUser(data);
    LocalUserDataNotifier.updateUserData(data);
  }
}