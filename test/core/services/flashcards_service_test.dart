import 'package:drift/drift.dart';
import 'package:flasholator/core/services/db_wrapper.dart';
import 'package:flasholator/core/services/flashcards_service.dart';
import 'package:flutter_test/flutter_test.dart';

class MemoryDatabase extends DatabaseWrapper {
  final cards = <FlashcardData>[];
  final inserted = <FlashcardsCompanion>[];
  final updated = <FlashcardsCompanion>[];
  MemoryDatabase();
  @override Future<void> init() async {}
  @override Future<int> count() async => cards.length;
  @override Future<List<FlashcardData>> getAll() async => List.of(cards);
  @override Future<bool> cardExists(String front, String back) async => cards.any((c) => c.front == front && c.back == back);
  @override Future<int> add(FlashcardsCompanion card) async { inserted.add(card); return inserted.length; }
  @override Future<void> put(FlashcardsCompanion card) async {
    updated.add(card);
  }
}

void main() {
  final now = DateTime.utc(2026, 1, 1);
  test('adds both directions once and refuses empty or duplicate pairs', () async {
    final db = MemoryDatabase();
    final service = FlashcardsService(database: db, clock: () => now);
    expect(await service.addFlashcard('bonjour', 'hello', 'FR', 'EN'), isTrue);
    expect(db.inserted, hasLength(2));
    expect(db.inserted.first.addedDate.value, now);
    expect(db.inserted[1].front.value, 'hello');
    expect(await service.addFlashcard('', 'hello', 'FR', 'EN'), isFalse);
    db.cards.add(FlashcardData(id: 1, front: 'bonjour', back: 'hello', sourceLang: 'FR', targetLang: 'EN', addedDate: now, easiness: 2.5, interval: 1, repetitions: 0, timesReviewed: 0));
    expect(await service.addFlashcard('bonjour', 'hello', 'FR', 'EN'), isFalse);
  });

  test('adds both directions with one shared clock instant', () async {
    var clockCalls = 0;
    final first = DateTime.utc(2026, 1, 1);
    final second = first.add(const Duration(seconds: 1));
    final db = MemoryDatabase();
    final service = FlashcardsService(
      database: db,
      clock: () => ++clockCalls == 1 ? first : second,
    );

    await service.addFlashcard('un', 'one', 'FR', 'EN');

    expect(clockCalls, 1);
    expect(db.inserted.map((card) => card.addedDate.value), [first, first]);
  });

  test('reviewing an absent card does not persist a mutation', () async {
    final db = MemoryDatabase();
    await FlashcardsService(database: db, clock: () => now).review('none', 'missing', 5);
    expect(db.inserted, isEmpty);
  });

  test('reviewing an existing card persists the deterministic SM-2 vector',
      () async {
    final db = MemoryDatabase()
      ..cards.add(FlashcardData(
        id: 3,
        front: 'bonjour',
        back: 'hello',
        sourceLang: 'FR',
        targetLang: 'EN',
        addedDate: now,
        easiness: 2.5,
        interval: 1,
        repetitions: 0,
        timesReviewed: 0,
      ));

    await FlashcardsService(database: db, clock: () => now)
        .review('bonjour', 'hello', 4);

    expect(db.updated, hasLength(1));
    final persisted = db.updated.single;
    expect(persisted.quality.value, 4);
    expect(persisted.easiness.value, 2.5);
    expect(persisted.interval.value, 1);
    expect(persisted.repetitions.value, 1);
    expect(persisted.timesReviewed.value, 1);
    expect(persisted.lastReviewDate.value, now);
    expect(persisted.nextReviewDate.value, now.add(const Duration(days: 1)));
  });

  test('dueFlashcards includes a card whose deadline is now', () async {
    final db = MemoryDatabase()
      ..cards.add(FlashcardData(
        id: 4,
        front: 'due',
        back: 'echue',
        sourceLang: 'FR',
        targetLang: 'EN',
        addedDate: now,
        easiness: 2.5,
        interval: 1,
        repetitions: 0,
        timesReviewed: 0,
        nextReviewDate: now,
      ))
      ..cards.add(FlashcardData(
        id: 5,
        front: 'later',
        back: 'plus tard',
        sourceLang: 'FR',
        targetLang: 'EN',
        addedDate: now,
        easiness: 2.5,
        interval: 1,
        repetitions: 0,
        timesReviewed: 0,
        nextReviewDate: now.add(const Duration(seconds: 1)),
      ));

    final due = await FlashcardsService(database: db, clock: () => now)
        .dueFlashcards();
    expect(due.map((card) => card.front), ['due']);
  });
}
