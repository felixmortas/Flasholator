import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flasholator/core/services/db_wrapper.dart';
import 'package:flasholator/features/flashcards/data/flashcard_repository.dart';
import 'package:flasholator/features/flashcards/domain/flashcard_collection.dart';
import 'package:flasholator/features/flashcards/domain/flashcard_pair.dart';
import 'package:flasholator/features/flashcards/domain/flashcard_pair_mutation_result.dart';
import 'package:flasholator/features/flashcards/domain/flashcard_review_result.dart';
import 'package:flasholator/features/flashcards/flashcard_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final class _FakeFlashcardRepository implements FlashcardRepository {
  _FakeFlashcardRepository([FlashcardCollectionSnapshot? snapshot])
      : snapshot = snapshot ??
            FlashcardCollectionSnapshot(version: 0, cards: const []);

  final FlashcardCollectionSnapshot snapshot;

  @override
  Future<FlashcardCollectionSnapshot> loadCollection() async => snapshot;

  @override
  Stream<FlashcardCollectionSnapshot> watchCollection() =>
      Stream.value(snapshot);

  @override
  Future<FlashcardPairMutationResult> addPair(FlashcardPair pair) async =>
      FlashcardPairMutationResult.applied;

  @override
  Future<FlashcardPairMutationResult> deletePair(FlashcardPair pair) async =>
      FlashcardPairMutationResult.applied;

  @override
  Future<FlashcardPairMutationResult> editPair({
    required FlashcardPair source,
    required FlashcardPair replacement,
  }) async =>
      FlashcardPairMutationResult.applied;

  @override
  Future<FlashcardReviewResult> reviewCard(
          {required int id, required int quality}) async =>
      FlashcardReviewResult.applied;
}

void main() {
  final now = DateTime.utc(2026, 1, 1, 12);
  FlashcardPair pair({
    String front = 'bonjour',
    String back = 'hello',
    String sourceLang = 'FR',
    String targetLang = 'EN',
  }) =>
      FlashcardPair(
        front: front,
        back: back,
        sourceLang: sourceLang,
        targetLang: targetLang,
      );

  Future<AppDatabase> database() async => AppDatabase(NativeDatabase.memory());

  Future<List<FlashcardData>> snapshot(AppDatabase db) async {
    final cards = await db.select(db.flashcards).get();
    cards.sort((left, right) => left.id.compareTo(right.id));
    return cards;
  }

  test('ajoute exactement deux faces inversées avec une date commune',
      () async {
    final db = await database();
    addTearDown(db.close);
    final repository = DriftFlashcardRepository(db, clock: () => now);

    expect(
        await repository.addPair(pair()), FlashcardPairMutationResult.applied);
    final cards = await db.select(db.flashcards).get();
    expect(cards, hasLength(2));
    expect(cards.map((card) => card.addedDate.toUtc()),
        unorderedEquals([now, now]));
    expect(
        cards.map((card) => card.front), unorderedEquals(['bonjour', 'hello']));
    expect(cards.map((card) => card.sourceLang), unorderedEquals(['FR', 'EN']));
  });

  test('vérifie le plafond dans la transaction, sans publier une paire de trop',
      () async {
    final db = await database();
    addTearDown(db.close);
    int? maximum = 1;
    final repository = DriftFlashcardRepository(
      db, maxCardPairs: () => maximum);
    expect(await repository.addPair(pair()), FlashcardPairMutationResult.applied);
    expect(
      await repository.addPair(pair(front: 'merci', back: 'thanks')),
      FlashcardPairMutationResult.limitReached,
    );
    expect(await snapshot(db), hasLength(2));
    maximum = null;
    expect(
      await repository.addPair(pair(front: 'merci', back: 'thanks')),
      FlashcardPairMutationResult.applied,
    );
    expect(await snapshot(db), hasLength(4));
  });

  test('modifie les deux faces et préserve les métadonnées persistées',
      () async {
    final db = await database();
    addTearDown(db.close);
    final repository = DriftFlashcardRepository(db, clock: () => now);
    final source = pair();
    expect(
        await repository.addPair(source), FlashcardPairMutationResult.applied);
    final original = await db.select(db.flashcards).get();
    for (final card in original) {
      await db.update(db.flashcards).replace(card.copyWith(
            quality: const Value(4),
            easiness: 2.36,
            interval: 6,
            repetitions: 2,
            timesReviewed: 3,
            lastReviewDate: Value(now),
            nextReviewDate: Value(now.add(const Duration(days: 6))),
          ));
    }

    final result = await repository.editPair(
      source: source,
      replacement: pair(front: 'merci', back: 'thanks'),
    );

    expect(result, FlashcardPairMutationResult.applied);
    final edited = await db.select(db.flashcards).get();
    expect(
      edited.map((card) => card.id),
      unorderedEquals(original.map((card) => card.id)),
    );
    for (final card in edited) {
      expect(card.addedDate.toUtc(), now);
      expect(card.quality, 4);
      expect(card.easiness, 2.36);
      expect(card.interval, 6);
      expect(card.repetitions, 2);
      expect(card.timesReviewed, 3);
      expect(card.lastReviewDate!.toUtc(), now);
      expect(
        card.nextReviewDate!.toUtc(),
        now.add(const Duration(days: 6)),
      );
    }
    expect(
        edited.map((card) => card.front), unorderedEquals(['merci', 'thanks']));
  });

  test('supprime une paire complète de façon atomique', () async {
    final db = await database();
    addTearDown(db.close);
    final repository = DriftFlashcardRepository(db, clock: () => now);
    final source = pair();
    await repository.addPair(source);

    expect(await repository.deletePair(source),
        FlashcardPairMutationResult.applied);
    expect(await db.select(db.flashcards).get(), isEmpty);
  });

  test('retourne notFound sans modifier une paire absente', () async {
    final db = await database();
    addTearDown(db.close);
    final repository = DriftFlashcardRepository(db, clock: () => now);
    final missing = pair();

    expect(await repository.deletePair(missing),
        FlashcardPairMutationResult.notFound);
    expect(
      await repository.editPair(
          source: missing, replacement: pair(front: 'a', back: 'b')),
      FlashcardPairMutationResult.notFound,
    );
    expect(await db.select(db.flashcards).get(), isEmpty);
  });

  test('refuse sans écrire les paires existantes, incomplètes ou ambiguës',
      () async {
    final db = await database();
    addTearDown(db.close);
    final repository = DriftFlashcardRepository(db, clock: () => now);
    final source = pair();
    await repository.addPair(source);
    final beforeConflict = await snapshot(db);
    expect(
        await repository.addPair(source), FlashcardPairMutationResult.conflict);
    expect(await snapshot(db), beforeConflict);

    expect(
      await repository.addPair(
        pair(
            front: 'hello',
            back: 'bonjour',
            sourceLang: 'EN',
            targetLang: 'FR'),
      ),
      FlashcardPairMutationResult.conflict,
    );
    expect(await snapshot(db), beforeConflict);

    await db.into(db.flashcards).insert(FlashcardsCompanion.insert(
          front: source.face.front,
          back: source.face.back,
          sourceLang: source.face.sourceLang,
          targetLang: source.face.targetLang,
          addedDate: now,
          easiness: 2.5,
          interval: 1,
          repetitions: 0,
          timesReviewed: 0,
        ));
    final ambiguous = await snapshot(db);
    expect(await repository.deletePair(source),
        FlashcardPairMutationResult.conflict);
    expect(await snapshot(db), ambiguous);

    final incomplete = pair(front: 'au revoir', back: 'goodbye');
    await db.into(db.flashcards).insert(FlashcardsCompanion.insert(
          front: incomplete.face.front,
          back: incomplete.face.back,
          sourceLang: incomplete.face.sourceLang,
          targetLang: incomplete.face.targetLang,
          addedDate: now,
          easiness: 2.5,
          interval: 1,
          repetitions: 0,
          timesReviewed: 0,
        ));
    final beforeIncompleteMutation = await snapshot(db);
    expect(
      await repository.editPair(
        source: incomplete,
        replacement: pair(front: 'ciao', back: 'bye'),
      ),
      FlashcardPairMutationResult.conflict,
    );
    expect(await snapshot(db), beforeIncompleteMutation);
  });

  test('restaure le snapshot si la seconde écriture échoue', () async {
    final db = await database();
    addTearDown(db.close);
    final repository = DriftFlashcardRepository(db, clock: () => now);
    await db.customStatement('''
      CREATE TRIGGER reject_second_face BEFORE INSERT ON flashcards
      WHEN NEW.front = 'hello'
      BEGIN SELECT RAISE(ABORT, 'échec voulu'); END;
    ''');

    await expectLater(repository.addPair(pair()), throwsA(isA<Object>()));
    expect(await db.select(db.flashcards).get(), isEmpty);
  });

  test('ignore sans lever les lignes legacy invalides hors de la paire ciblée',
      () async {
    final db = await database();
    addTearDown(db.close);
    final repository = DriftFlashcardRepository(db, clock: () => now);
    await db.into(db.flashcards).insert(FlashcardsCompanion.insert(
          front: 'legacy',
          back: 'invalid',
          sourceLang: '',
          targetLang: 'EN',
          addedDate: now,
          easiness: 2.5,
          interval: 1,
          repetitions: 0,
          timesReviewed: 0,
        ));

    expect(
        await repository.addPair(pair()), FlashcardPairMutationResult.applied);
    expect(await db.select(db.flashcards).get(), hasLength(3));
  });

  test('refuse une modification vers une paire destination existante',
      () async {
    final db = await database();
    addTearDown(db.close);
    final repository = DriftFlashcardRepository(db, clock: () => now);
    final source = pair();
    final destination = pair(front: 'merci', back: 'thanks');
    await repository.addPair(source);
    await repository.addPair(destination);
    final before = await snapshot(db);

    expect(
      await repository.editPair(source: source, replacement: destination),
      FlashcardPairMutationResult.conflict,
    );
    expect(await snapshot(db), before);
  });

  test('restaure le snapshot si la seconde modification échoue', () async {
    final db = await database();
    addTearDown(db.close);
    final repository = DriftFlashcardRepository(db, clock: () => now);
    final source = pair();
    await repository.addPair(source);
    final before = await snapshot(db);
    await db.customStatement('''
      CREATE TRIGGER reject_second_update BEFORE UPDATE ON flashcards
      WHEN NEW.front = 'thanks'
      BEGIN SELECT RAISE(ABORT, 'échec voulu'); END;
    ''');

    await expectLater(
      repository.editPair(
        source: source,
        replacement: pair(front: 'merci', back: 'thanks'),
      ),
      throwsA(isA<Object>()),
    );
    expect(await snapshot(db), before);
  });

  test(
      'la clé canonique ne dépend pas de l’orientation et les entrées sont validées',
      () {
    expect(
        pair().key,
        pair(
                front: 'hello',
                back: 'bonjour',
                sourceLang: 'EN',
                targetLang: 'FR')
            .key);
    expect(
      () => pair(front: ' ', back: 'hello'),
      throwsArgumentError,
    );
  });

  test(
      'les providers dérivent collection et projections de la même version surchargée',
      () async {
    final snapshot = FlashcardCollectionSnapshot(version: 42, cards: [
      PersistedFlashcard(
        id: 1,
        front: 'bonjour',
        back: 'hello',
        sourceLang: 'FR',
        targetLang: 'EN',
        addedDate: now,
        quality: null,
        easiness: 2.5,
        interval: 1,
        repetitions: 0,
        timesReviewed: 0,
        lastReviewDate: null,
        nextReviewDate: null,
      ),
      PersistedFlashcard(
        id: 2,
        front: 'hello',
        back: 'bonjour',
        sourceLang: 'EN',
        targetLang: 'FR',
        addedDate: now,
        quality: null,
        easiness: 2.5,
        interval: 1,
        repetitions: 0,
        timesReviewed: 0,
        lastReviewDate: null,
        nextReviewDate: null,
      ),
    ]);
    final fake = _FakeFlashcardRepository(snapshot);
    final container = ProviderContainer(
      overrides: [flashcardRepositoryProvider.overrideWithValue(fake)],
    );
    addTearDown(container.dispose);

    expect(container.read(flashcardRepositoryProvider), same(fake));
    expect(await container.read(flashcardCollectionProvider.future),
        same(snapshot));
    expect(
        container.read(flashcardReviewProjectionProvider).requireValue.version,
        42);
    expect(
        container.read(flashcardTableProjectionProvider).requireValue.version,
        42);
    expect(
        container
            .read(flashcardStatisticsProjectionProvider)
            .requireValue
            .version,
        42);
  });

  test('charge une base historique sans altérer les treize champs', () async {
    final db = await database();
    addTearDown(db.close);
    await db.into(db.flashcards).insert(FlashcardsCompanion.insert(
          front: 'bonjour',
          back: 'hello',
          sourceLang: 'FR',
          targetLang: 'EN',
          addedDate: now,
          quality: const Value(3),
          easiness: 2.3,
          interval: 4,
          repetitions: 2,
          timesReviewed: 7,
          lastReviewDate: Value(now.subtract(const Duration(days: 1))),
          nextReviewDate: Value(now.add(const Duration(days: 4))),
        ));
    final repository = DriftFlashcardRepository(db);

    final collection = await repository.loadCollection();
    final card = collection.cards.single;
    expect(collection.version, 0);
    expect(card.id, 1);
    expect(card.front, 'bonjour');
    expect(card.back, 'hello');
    expect(card.sourceLang, 'FR');
    expect(card.targetLang, 'EN');
    expect(card.addedDate.toUtc(), now);
    expect(card.quality, 3);
    expect(card.easiness, 2.3);
    expect(card.interval, 4);
    expect(card.repetitions, 2);
    expect(card.timesReviewed, 7);
    expect(card.lastReviewDate!.toUtc(), now.subtract(const Duration(days: 1)));
    expect(card.nextReviewDate!.toUtc(), now.add(const Duration(days: 4)));
  });

  test('publie uniquement après un commit appliqué', () async {
    final db = await database();
    addTearDown(db.close);
    final repository = DriftFlashcardRepository(db, clock: () => now);
    final snapshots = <FlashcardCollectionSnapshot>[];
    final subscription = repository.watchCollection().listen(snapshots.add);
    addTearDown(subscription.cancel);

    await Future<void>.delayed(Duration.zero);
    expect(
        await repository.addPair(pair()), FlashcardPairMutationResult.applied);
    await Future<void>.delayed(Duration.zero);
    expect(snapshots.map((snapshot) => snapshot.version), [0, 1]);
    expect(snapshots.last.cards, hasLength(2));

    expect(
        await repository.addPair(pair()), FlashcardPairMutationResult.conflict);
    expect(await repository.deletePair(pair(front: 'absente', back: 'missing')),
        FlashcardPairMutationResult.notFound);
    await Future<void>.delayed(Duration.zero);
    expect(snapshots.map((snapshot) => snapshot.version), [0, 1]);
  });

  test('les lignes legacy isolées restent lisibles dans le snapshot', () async {
    final db = await database();
    addTearDown(db.close);
    await db.into(db.flashcards).insert(FlashcardsCompanion.insert(
          front: 'isolée',
          back: 'orphan',
          sourceLang: '',
          targetLang: 'EN',
          addedDate: now,
          easiness: 2.5,
          interval: 1,
          repetitions: 0,
          timesReviewed: 0,
        ));

    final collection = await DriftFlashcardRepository(db).loadCollection();
    expect(collection.cards, hasLength(1));
    expect(collection.cards.single.sourceLang, '');
    expect(collection.cards.single.front, 'isolée');
  });

  test('termine une mutation déjà en file avant de fermer sa publication',
      () async {
    final db = await database();
    addTearDown(db.close);
    final repository = DriftFlashcardRepository(db, clock: () => now);

    final mutation = repository.addPair(pair());
    final disposal = repository.dispose();

    expect(await mutation, FlashcardPairMutationResult.applied);
    await disposal;
    expect(await db.select(db.flashcards).get(), hasLength(2));
  });

  test('conserve la dernière publication quand la transaction échoue',
      () async {
    final db = await database();
    addTearDown(db.close);
    final repository = DriftFlashcardRepository(db, clock: () => now);
    final snapshots = <FlashcardCollectionSnapshot>[];
    final subscription = repository.watchCollection().listen(snapshots.add);
    addTearDown(subscription.cancel);
    await Future<void>.delayed(Duration.zero);
    await db.customStatement('''
      CREATE TRIGGER reject_second_face BEFORE INSERT ON flashcards
      WHEN NEW.front = 'hello'
      BEGIN SELECT RAISE(ABORT, 'échec voulu'); END;
    ''');

    await expectLater(repository.addPair(pair()), throwsA(isA<Object>()));
    await Future<void>.delayed(Duration.zero);
    expect(snapshots.map((snapshot) => snapshot.version), [0]);
    expect((await repository.loadCollection()).cards, isEmpty);
  });

  test(
      'publie un snapshot suivant pour une édition puis une suppression appliquées',
      () async {
    final db = await database();
    addTearDown(db.close);
    final repository = DriftFlashcardRepository(db, clock: () => now);
    final source = pair();
    expect(
        await repository.addPair(source), FlashcardPairMutationResult.applied);

    final received = repository.watchCollection().take(3).toList();
    await Future<void>.delayed(Duration.zero);
    final replacement = pair(front: 'merci', back: 'thanks');
    expect(
      await repository.editPair(source: source, replacement: replacement),
      FlashcardPairMutationResult.applied,
    );
    expect(await repository.deletePair(replacement),
        FlashcardPairMutationResult.applied);

    final snapshots = await received;
    expect(snapshots.map((snapshot) => snapshot.version), [1, 2, 3]);
    expect(snapshots[1].cards.map((card) => card.front), ['merci', 'thanks']);
    expect(snapshots[2].cards, isEmpty);
  });

  test(
      'révise une carte par son id, conserve ses autres champs et publie après commit',
      () async {
    final db = await database();
    addTearDown(db.close);
    final reviewedAt = DateTime.utc(2026, 2, 1, 9);
    final repository = DriftFlashcardRepository(db, clock: () => reviewedAt);
    await repository.addPair(pair());
    final cards = await snapshot(db);
    final id = cards.first.id;
    final snapshots = <FlashcardCollectionSnapshot>[];
    final subscription = repository.watchCollection().listen(snapshots.add);
    addTearDown(subscription.cancel);
    await Future<void>.delayed(Duration.zero);

    expect(await repository.reviewCard(id: id, quality: 4),
        FlashcardReviewResult.applied);
    await Future<void>.delayed(Duration.zero);
    final card = (await snapshot(db)).firstWhere((card) => card.id == id);
    expect(card.front, cards.first.front);
    expect(card.addedDate, cards.first.addedDate);
    expect(card.quality, 4);
    expect(card.repetitions, 1);
    expect(card.timesReviewed, 1);
    expect(card.lastReviewDate!.isAtSameMomentAs(reviewedAt), isTrue);
    expect(
      card.nextReviewDate!
          .isAtSameMomentAs(reviewedAt.add(const Duration(days: 1))),
      isTrue,
    );
    expect(snapshots.map((snapshot) => snapshot.version), [1, 2]);
  });

  test('une révision échouée ne publie pas de snapshot de succès', () async {
    final db = await database();
    addTearDown(db.close);
    final repository = DriftFlashcardRepository(db, clock: () => now);
    await repository.addPair(pair());
    final id = (await snapshot(db)).first.id;
    final snapshots = <FlashcardCollectionSnapshot>[];
    final subscription = repository.watchCollection().listen(snapshots.add);
    addTearDown(subscription.cancel);
    await Future<void>.delayed(Duration.zero);
    await db.customStatement('''
      CREATE TRIGGER reject_review BEFORE UPDATE ON flashcards
      WHEN NEW.id = $id BEGIN SELECT RAISE(ABORT, 'échec voulu'); END;
    ''');

    await expectLater(
        repository.reviewCard(id: id, quality: 4), throwsA(isA<Object>()));
    await Future<void>.delayed(Duration.zero);
    expect(snapshots.map((snapshot) => snapshot.version), [1]);
  });
}
