// user_preferences_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferencesService {
  static const _isSubscribedKey = 'isSubscribed';
  static const _canTranslateKey = 'canTranslate';
  static const _subscriptionDateKey = 'subscriptionDate';
  static const _subscriptionEndDateKey = 'subscriptionEndDate';
  static const _userDataCachedKey = 'userDataCached';

  /// Enregistre les champs utilisateur localement
  static Future<void> updateUser(Map<String, dynamic> fields) async {
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

    // Met à jour le cache utilisateur si nécessaire
    await _updateCachedFlag(prefs, fields);
  }

  /// Charge les données utilisateur depuis SharedPreferences
  static Future<Map<String, dynamic>> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'isSubscribed': prefs.getBool(_isSubscribedKey) ?? false,
      'canTranslate': prefs.getBool(_canTranslateKey) ?? true,
      'subscriptionDate': prefs.getString(_subscriptionDateKey),
      'subscriptionEndDate': prefs.getString(_subscriptionEndDateKey),
    };
  }

  /// Vérifie si les données utilisateur sont déjà en cache
  static Future<bool> isUserDataCached() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_userDataCachedKey) ?? false;
  }

  /// Supprime toutes les données utilisateur enregistrées localement
  static Future<void> deleteUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isSubscribedKey);
    await prefs.remove(_canTranslateKey);
    await prefs.remove(_subscriptionDateKey);
    await prefs.remove(_subscriptionEndDateKey);
    await prefs.setBool(_userDataCachedKey, false);
  }

  /// Marque les données utilisateur comme étant mises en cache
  static Future<void> _updateCachedFlag(
      SharedPreferences prefs, Map<String, dynamic> fields) async {
    const watchedKeys = {
      _isSubscribedKey,
      _canTranslateKey,
      _subscriptionDateKey,
      _subscriptionEndDateKey,
    };

    if (fields.keys.toSet().intersection(watchedKeys).isNotEmpty) {
      await prefs.setBool(_userDataCachedKey, true);
    }
  }
}