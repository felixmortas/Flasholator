import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class DatabaseWrapper<T> {
  final String boxName;
  late Box<T> _box;

  DatabaseWrapper(this.boxName);

  /// Initialisation de la boîte
  Future<void> init() async {
    _box = await Hive.openBox<T>(boxName);
    debugPrint('Hive box initialized: $boxName');
  }

  /// Récupérer tous les enregistrements
  Future<List<T>> getAll() async {
    return _box.values.toList();
  }

  /// Récupérer un élément par clé
  Future<T?> get(dynamic key) async {
    return _box.get(key);
  }

  /// Ajouter un élément et retourner la clé
  Future<dynamic> add(T item) async {
    return _box.add(item);
  }

  /// Ajouter plusieurs éléments
  Future<void> addAll(Iterable<T> items) async {
    await _box.addAll(items);
  }

  /// Mettre à jour un élément par clé
  Future<void> put(dynamic key, T item) async {
    await _box.put(key, item);
  }

  /// Supprimer un élément par clé
  Future<void> delete(dynamic key) async {
    await _box.delete(key);
  }

  /// Supprimer plusieurs éléments
  Future<void> deleteAll(Iterable<dynamic> keys) async {
    await _box.deleteAll(keys);
  }

  /// Nombre total d'éléments
  int count() {
    return _box.length;
  }

  /// Map clé → valeur
  Map<dynamic, T> toMap() {
    return _box.toMap();
  }

  /// Fermer la boîte
  Future<void> close() async {
    await _box.close();
  }
}
