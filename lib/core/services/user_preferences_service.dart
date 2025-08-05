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

  static Future<void> saveUserFieldsLocally(Map<String, dynamic> fields) async {
    final prefs = await SharedPreferences.getInstance();

    for (final entry in fields.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is String) {
        await prefs.setString(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is double) {
        await prefs.setDouble(key, value);
      } else {
        throw ArgumentError('Type non supporté pour la clé $key');
      }
    }

    // Clés à surveiller pour le notifier
    const watchedKeys = {
      _isSubscribedKey,
      _canTranslateKey,
      _subscriptionDateKey,
      _subscriptionEndDateKey,
    };

    // Si au moins une des clés modifiées impacte userDataNotifier
    if (fields.keys.toSet().intersection(watchedKeys).isNotEmpty) {
      userDataNotifier.value = {
        'isSubscribed': prefs.getBool(_isSubscribedKey) ?? false,
        'canTranslate': prefs.getBool(_canTranslateKey) ?? true,
        'subscriptionDate': prefs.getString(_subscriptionDateKey),
        'subscriptionEndDate': prefs.getString(_subscriptionEndDateKey),
      };
    }
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
