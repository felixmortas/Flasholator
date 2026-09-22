import 'package:shared_preferences/shared_preferences.dart';

class UserPreferencesService {
  static Future<void> _writes = Future<void>.value();

  static Future<T> _serialize<T>(Future<T> Function() action) {
    final result = _writes.then((_) => action());
    _writes = result.then<void>((_) {}, onError: (_, __) {});
    return result;
  }
  static const _canTranslateKey = 'canTranslate';
  static const _counterKey = 'counter';
  static const _userDataCachedKey = 'userDataCached';
  static const _coupleLangKey = 'coupleLang';
  static const _usedLanguagePairsKey = 'usedLanguagePairs';
  static const _isSubscribedKey = 'isSubscribed';
  static const _cacheOwnerUidKey = 'userCacheOwnerUid';

  // ====================
  // === READ METHODS ===
  // ====================

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

  static Future<String?> getCacheOwnerUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cacheOwnerUidKey);
  }

  static Future<String> getCoupleLang() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_coupleLangKey) ?? '';
  }

  static String _pairsKey(String? uid) => uid == null
      ? _usedLanguagePairsKey
      : '$_usedLanguagePairsKey.$uid';

  static Future<List<String>> getUsedLanguagePairs({String? uid}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_pairsKey(uid)) ?? <String>[];
  }

  static Future<void> setUsedLanguagePairs(List<String> pairs,
      {String? uid, bool Function()? isCurrent}) => _serialize(() async {
    if (isCurrent != null && !isCurrent()) return;
    final prefs = await SharedPreferences.getInstance();
    if (isCurrent != null && !isCurrent()) return;
    await prefs.setStringList(_pairsKey(uid), pairs);
  });

  // =====================
  // === WRITE METHODS ===
  // =====================

  /// Enregistre les champs utilisateur localement
  static Future<void> updateUser(Map<String, dynamic> fields,
      {String? uid, bool Function()? isCurrent}) => _serialize(() async {
    if (isCurrent != null && !isCurrent()) return;
    final prefs = await SharedPreferences.getInstance();

    for (final entry in fields.entries) {
      final key = entry.key;
      final value = entry.value;
      if (isCurrent != null && !isCurrent()) return;

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

    if (isCurrent == null || isCurrent()) {
      await _updateCachedFlag(prefs, fields);
      if (uid != null) await prefs.setString(_cacheOwnerUidKey, uid);
    }
  });

  /// Supprime toutes les données utilisateur enregistrées localement
  static Future<void> deleteUser({String? uid}) => _serialize(() async {
    await _clearUserData();
    if (uid != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_pairsKey(uid));
    }
  });

  static Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_canTranslateKey);
    await prefs.remove(_counterKey);
    await prefs.setBool(_userDataCachedKey, false);
    await prefs.remove(_coupleLangKey);
    await prefs.remove(_usedLanguagePairsKey);
    await prefs.remove(_isSubscribedKey);
    await prefs.remove(_cacheOwnerUidKey);
  }

  /// Clear all user data
  static Future<void> clearUserData() => _serialize(_clearUserData);

  // =========================
  // === BULK LOAD METHOD ===
  // =========================

  /// Charge toutes les données utilisateur d’un coup
  static Future<Map<String, dynamic>> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'canTranslate': prefs.getBool(_canTranslateKey) ?? true,
      'counter': prefs.getInt(_counterKey) ?? 0,
      'coupleLang': prefs.getString(_coupleLangKey) ?? '',
    };
  }

  // =========================
  // === INTERNAL HELPERS ===
  // =========================

  /// Marque les données utilisateur comme étant mises en cache si certains champs sont mis à jour
  static Future<void> _updateCachedFlag(
      SharedPreferences prefs, Map<String, dynamic> fields) async {
    const watchedKeys = {
      _canTranslateKey,
      _coupleLangKey,
      _counterKey,
    };

    if (fields.keys.toSet().intersection(watchedKeys).isNotEmpty) {
      await prefs.setBool(_userDataCachedKey, true);
    }
  }
}
