import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

part 'db_wrapper.g.dart';

// --- 1. Définition de la table ---
// C'est ici que l'on décrit la structure de notre table de flashcards.
// Drift utilisera ceci pour générer la classe de données `FlashcardData` et le `FlashcardsCompanion`.

@DataClassName('FlashcardData')
class Flashcards extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get front => text()();
  TextColumn get back => text()();
  TextColumn get sourceLang => text()();
  TextColumn get targetLang => text()();
  DateTimeColumn get addedDate => dateTime()();
  IntColumn get quality => integer().nullable()();
  RealColumn get easiness => real()();
  IntColumn get interval => integer()();
  IntColumn get repetitions => integer()();
  IntColumn get timesReviewed => integer()();
  DateTimeColumn get lastReviewDate => dateTime().nullable()();
  DateTimeColumn get nextReviewDate => dateTime().nullable()();
}


// --- 2. Classe de la base de données Drift ---
// C'est le cœur de Drift. Elle connecte les définitions de tables à un fichier de base de données.
@DriftDatabase(tables: [Flashcards])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'flashcards_collection',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }
}

// --- 3. Le Wrapper ---
// C'est la classe que votre `FlashcardsService` utilisera.
// Elle masque complètement la complexité de Drift.
class DatabaseWrapper {
  late AppDatabase _db;

  /// Initialisation de la base de données. Doit être appelée avant toute autre opération.
  Future<void> init() async {
    _db = AppDatabase();
  }

  /// Récupérer tous les enregistrements
  Future<List<FlashcardData>> getAll() async {
    return await _db.select(_db.flashcards).get();
  }

  /// Récupérer un élément par son ID (clé primaire)
  Future<FlashcardData?> get(int id) async {
    return (_db.select(_db.flashcards)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  /// Ajouter un élément et retourner son nouvel ID.
  /// On utilise un "Companion" pour l'insertion.
  Future<int> add(FlashcardsCompanion item) async {
    return await _db.into(_db.flashcards).insert(item);
  }

  /// Ajouter plusieurs éléments en une seule transaction (plus performant)
  Future<void> addAll(List<FlashcardsCompanion> items) async {
    await _db.batch((batch) {
      batch.insertAll(_db.flashcards, items);
    });
  }

  /// Mettre à jour un élément existant ou en créer un nouveau.
  Future<void> put(FlashcardsCompanion item) async {
    await _db.update(_db.flashcards).replace(item);
  }

  /// Supprimer un élément par son ID
  Future<int> delete(int id) async {
    return await (_db.delete(_db.flashcards)..where((tbl) => tbl.id.equals(id))).go();
  }

  /// Supprimer plusieurs éléments par leurs IDs
  Future<int> deleteAll(List<int> ids) async {
    return await (_db.delete(_db.flashcards)..where((tbl) => tbl.id.isIn(ids))).go();
  }

  /// Compter le nombre total d'éléments
  Future<int> count() async {
    final expression = _db.flashcards.id.count();
    final query = _db.selectOnly(_db.flashcards)..addColumns([expression]);
    final result = await query.getSingle();
    // `read` retourne une valeur nullable, on met 0 par défaut.
    return result.read(expression) ?? 0;
  }

  /// Retourne une Map des éléments avec leur ID comme clé.
  Future<Map<int, FlashcardData>> toMap() async {
    final allItems = await getAll();
    return { for (var item in allItems) item.id : item };
  }

  /// Fermer la connexion à la base de données
  Future<void> close() async {
    await _db.close();
  }

  /// Vérifie l'existence d'une carte de manière optimisée
  Future<bool> cardExists(String front, String back) async {
    final query = _db.select(_db.flashcards)
      ..where((tbl) => tbl.front.equals(front) & tbl.back.equals(back));
    final result = await query.get();
    return result.isNotEmpty;
  }

  /// Récupère uniquement les cartes échues depuis la base de données
  Future<List<FlashcardData>> getDueFlashcards(DateTime now) async {
    final query = _db.select(_db.flashcards)
      ..where((tbl) => 
        tbl.nextReviewDate.isNull() |
        tbl.nextReviewDate.isSmallerOrEqualValue(now));
    return await query.get();
  }
}