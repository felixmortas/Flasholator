import 'package:flasholator/features/flashcards/application/flashcard_collection_projections.dart';
import 'package:flasholator/features/flashcards/domain/flashcard_collection.dart';
import 'package:flutter_test/flutter_test.dart';

PersistedFlashcard card({
  required int id,
  required String front,
  required String back,
  required String source,
  required String target,
  DateTime? nextReviewDate,
  DateTime? addedDate,
  int reviewed = 0,
}) =>
    PersistedFlashcard(
      id: id,
      front: front,
      back: back,
      sourceLang: source,
      targetLang: target,
      addedDate: addedDate ?? DateTime.utc(2026, 1, 1),
      quality: null,
      easiness: 2.5,
      interval: 1,
      repetitions: 0,
      timesReviewed: reviewed,
      lastReviewDate: null,
      nextReviewDate: nextReviewDate,
    );

void main() {
  test('review, table et statistiques dérivent de la même version sans modifier le snapshot', () {
    final now = DateTime.utc(2026, 1, 2);
    final snapshot = FlashcardCollectionSnapshot(version: 7, cards: [
      card(id: 2, front: 'hello', back: 'bonjour', source: 'EN', target: 'FR', reviewed: 8),
      card(id: 1, front: 'bonjour', back: 'hello', source: 'FR', target: 'EN', reviewed: 9),
      card(
        id: 3,
        front: 'legacy',
        back: 'isolée',
        source: 'FR',
        target: 'EN',
        reviewed: 99,
      ),
    ]);

    final review = FlashcardCollectionProjections.review(snapshot, now: now);
    final table = FlashcardCollectionProjections.table(snapshot);
    final statistics = FlashcardCollectionProjections.statistics(snapshot);

    expect(review.version, 7);
    expect(table.version, 7);
    expect(review.cards, hasLength(3));
    expect(table.pairs, hasLength(1));
    expect(table.pairs.single.card.id, 1);
    expect(statistics.totalWords, 1);
    expect(statistics.totalPairs, 1);
    expect(statistics.mostReviewed.first.word, 'bonjour');
    expect(
      statistics.mostReviewed.map((item) => item.word),
      isNot(contains('legacy')),
    );
    expect(statistics.dailySeries, hasLength(1));
    expect(statistics.dailySeries.single.date, DateTime(2026, 1, 1));
    expect(statistics.dailySeries.single.count, 1);
    expect(statistics.dailyAverage, 1);
    expect(statistics.weeklyAverage, 1);
    expect(statistics.monthlyAverage, 1);
    expect(statistics.yearlyAverage, 1);
    expect(snapshot.cards.map((item) => item.id), [2, 1, 3]);
  });

  test('une paire inversée est dédoublonnée et une ligne isolée ne masque pas les autres', () {
    final snapshot = FlashcardCollectionSnapshot(version: 1, cards: [
      card(id: 10, front: 'world', back: 'monde', source: 'EN', target: 'FR'),
      card(id: 11, front: 'monde', back: 'world', source: 'FR', target: 'EN'),
      card(id: 12, front: 'orpheline', back: 'orphan', source: 'FR', target: 'EN'),
    ]);

    expect(FlashcardCollectionProjections.table(snapshot).pairs, hasLength(1));
  });

  test('sélectionne une paire complète parmi doublons et conserve une date de paire cohérente', () {
    final snapshot = FlashcardCollectionSnapshot(version: 8, cards: [
      card(id: 1, front: 'chat', back: 'cat', source: 'FR', target: 'EN', addedDate: DateTime.utc(2026, 1, 3)),
      card(id: 2, front: 'cat', back: 'chat', source: 'EN', target: 'FR', addedDate: DateTime.utc(2026, 1, 1)),
      card(id: 3, front: 'chat', back: 'cat', source: 'FR', target: 'EN'),
      card(id: 4, front: 'legacy', back: 'isolée', source: 'FR', target: 'EN'),
    ]);

    final table = FlashcardCollectionProjections.table(snapshot);
    final statistics = FlashcardCollectionProjections.statistics(snapshot);

    expect(table.pairs, hasLength(1));
    expect(table.pairs.single.card.id, 1);
    expect(statistics.version, 8);
    expect(statistics.totalWords, 1);
    expect(statistics.dailySeries, hasLength(1));
    expect(statistics.dailySeries.single.date, DateTime(2026, 1, 1));
    expect(statistics.dailySeries.single.count, 1);
  });

  test('review conserve les cartes dues maintenant et sans échéance, mais ignore une échéance future', () {
    final now = DateTime.utc(2026, 1, 2, 12);
    final snapshot = FlashcardCollectionSnapshot(version: 2, cards: [
      card(
        id: 1,
        front: 'future',
        back: 'futur',
        source: 'EN',
        target: 'FR',
        nextReviewDate: now.add(const Duration(microseconds: 1)),
      ),
      card(
        id: 2,
        front: 'due',
        back: 'due',
        source: 'EN',
        target: 'FR',
        nextReviewDate: now,
      ),
      card(id: 3, front: 'new', back: 'nouvelle', source: 'EN', target: 'FR'),
    ]);

    final review = FlashcardCollectionProjections.review(snapshot, now: now);
    expect(review.cards.map((card) => card.id), [2, 3]);
  });
}
