import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferencesService {
  static const _isSubscribedKey = 'isSubscribed';
  static const _canTranslateKey = 'canTranslate';
  static const _subscriptionDateKey = 'subscriptionDate';
  static const _subscriptionEndDateKey = 'subscriptionEndDate';
  static const _userDataCachedKey = 'userDataCached';

  // ✅ Référence globale réactive
  static final ValueNotifier<Map<String, dynamic>> userDataNotifier =
      ValueNotifier<Map<String, dynamic>>({});

  static Future<void> saveUserDataLocally(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isSubscribedKey, data['isSubscribed'] ?? false);
    await prefs.setBool(_canTranslateKey, data['canTranslate'] ?? true);
    await prefs.setString(_subscriptionDateKey, data['subscriptionDate'] ?? '');
    await prefs.setString(_subscriptionEndDateKey, data['subscriptionEndDate'] ?? '');
    await prefs.setBool(_userDataCachedKey, true);

    // ✅ Met à jour le notifier
    userDataNotifier.value = {
      'isSubscribed': prefs.getBool(_isSubscribedKey) ?? false,
      'canTranslate': prefs.getBool(_canTranslateKey) ?? true,
      'subscriptionDate': prefs.getString(_subscriptionDateKey),
      'subscriptionEndDate': prefs.getString(_subscriptionEndDateKey),
    };
  }

  static Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    userDataNotifier.value = {
      'isSubscribed': prefs.getBool(_isSubscribedKey) ?? false,
      'canTranslate': prefs.getBool(_canTranslateKey) ?? true,
      'subscriptionDate': prefs.getString(_subscriptionDateKey),
      'subscriptionEndDate': prefs.getString(_subscriptionEndDateKey),
    };
  }

  static Future<bool> isUserDataCached() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_userDataCachedKey) ?? false;
  }
}
