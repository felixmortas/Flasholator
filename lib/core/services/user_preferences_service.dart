import 'package:shared_preferences/shared_preferences.dart';

class UserPreferencesService {
  static const _isSubscribedKey = 'isSubscribed';
  static const _canTranslateKey = 'canTranslate';
  static const _counterKey = 'counter';
  static const _userDataCachedKey = 'userDataCached';
  static const _coupleLangKey = 'coupleLang';

  // ====================
  // === READ METHODS ===
  // ====================

  static Future<bool> getIsSubscribed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isSubscribedKey) ?? false;
  }

  static Future<bool> getCanTranslate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_canTranslateKey) ?? true;
  }

  static Future<int> getCounter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_counterKey) ?? 0;
  }

  static Future<bool> isUserDataCached() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_userDataCachedKey) ?? false;
  }

  static Future<String> getCoupleLang() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_coupleLangKey) ?? '';
  }

  // =====================
  // === WRITE METHODS ===
  // =====================

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

    await _updateCachedFlag(prefs, fields);
  }

  /// Supprime toutes les données utilisateur enregistrées localement
  static Future<void> deleteUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isSubscribedKey);
    await prefs.remove(_canTranslateKey);
    await prefs.remove(_counterKey);
    await prefs.setBool(_userDataCachedKey, false);
    await prefs.remove(_coupleLangKey);
  }

  // =========================
  // === BULK LOAD METHOD ===
  // =========================

  /// Charge toutes les données utilisateur d’un coup
  static Future<Map<String, dynamic>> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'isSubscribed': prefs.getBool(_isSubscribedKey) ?? false,
      'canTranslate': prefs.getBool(_canTranslateKey) ?? true,
      'counter': prefs.getInt(_counterKey) ?? 0,
      'coupleLang': prefs.getString(_coupleLangKey) ?? '',
    };
  }

  // =========================
  // === INTERNAL HELPERS ===
  // =========================

  /// Marque les données utilisateur comme étant mises en cache si certains champs sont mis à jour
  static Future<void> _updateCachedFlag(SharedPreferences prefs, Map<String, dynamic> fields) async {
    const watchedKeys = {
      _isSubscribedKey,
      _canTranslateKey,
      _coupleLangKey,
    };

    if (fields.keys.toSet().intersection(watchedKeys).isNotEmpty) {
      await prefs.setBool(_userDataCachedKey, true);
    }
  }
}
