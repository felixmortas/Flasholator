import 'dart:async';

import 'package:flasholator/features/flashcards/flashcard_providers.dart';
import 'package:flasholator/features/flashcards/domain/flashcard_collection.dart';
import 'package:flasholator/features/stats/statistics_use_case.dart';
import 'package:flasholator/features/stats/stats_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

PersistedFlashcard _card(int id, String front, String back, String source,
        String target, DateTime date, int reviewed) =>
    PersistedFlashcard(
      id: id,
      front: front,
      back: back,
      sourceLang: source,
      targetLang: target,
      addedDate: date,
      quality: null,
      easiness: 2.5,
      interval: 1,
      repetitions: reviewed,
      timesReviewed: reviewed,
      lastReviewDate: null,
      nextReviewDate: null,
    );

void main() {
  const useCase = StatisticsUseCase();

  test('dédoublonne les paires et calcule séries et moyennes par paire', () {
    final first = DateTime(2026, 1, 1);
    final last = DateTime(2026, 1, 8);
    final snapshot = FlashcardCollectionSnapshot(version: 4, cards: [
      _card(1, 'bonjour', 'hello', 'FR', 'EN', first, 9),
      _card(2, 'hello', 'bonjour', 'EN', 'FR', first, 8),
      _card(3, 'bonjour', 'hello', 'FR', 'EN', first, 99),
      _card(4, 'salut', 'hi', 'FR', 'EN', last, 7),
      _card(5, 'hi', 'salut', 'EN', 'FR', last, 6),
      _card(6, 'orpheline', 'orphan', 'FR', 'EN', last, 100),
    ]);

    final result = useCase.calculate(snapshot);
    expect(result.version, 4);
    expect(result.totalWords, 2);
    expect(result.totalPairs, 1);
    expect(result.dailySeries.map((entry) => entry.count), [1, 1]);
    expect(result.dailyAverage, 2 / 8);
    expect(result.weeklyAverage, 2 / (8 / 7));
    expect(result.mostReviewed.first.word, 'bonjour');
    expect(result.mostReviewed.map((item) => item.word),
        isNot(contains('orpheline')));
    expect(snapshot.cards, hasLength(6));
  });

  test('filtre une paire entière par sa date la plus ancienne', () {
    final first = DateTime(2026, 1, 1);
    final later = DateTime(2026, 1, 3);
    final snapshot = FlashcardCollectionSnapshot(version: 2, cards: [
      _card(1, 'bonjour', 'hello', 'FR', 'EN', later, 2),
      _card(2, 'hello', 'bonjour', 'EN', 'FR', first, 1),
    ]);

    final included = useCase.calculate(snapshot, startDate: first, endDate: first);
    final excluded = useCase.calculate(snapshot, startDate: later, endDate: later);
    expect(included.totalWords, 1);
    expect(included.dailySeries.single.date, first);
    expect(excluded.totalWords, 0);
    expect(excluded.dailySeries, isEmpty);
    expect(excluded.dailyAverage, 0);
  });

  test('classe par valeur décroissante et limite chaque classement à cinq', () {
    final day = DateTime(2026, 1, 1);
    final cards = <PersistedFlashcard>[];
    for (var index = 0; index < 6; index++) {
      cards.add(_card(index * 2 + 1, 'fr$index', 'en$index', 'FR', 'EN',
          day, index));
      cards.add(_card(index * 2 + 2, 'en$index', 'fr$index', 'EN', 'FR',
          day, index));
    }
    final result = useCase.calculate(
        FlashcardCollectionSnapshot(version: 1, cards: cards));
    for (final ranking in [
      result.mostReviewed,
      result.mostSuccessful,
      result.easiest,
    ]) {
      expect(ranking, hasLength(5));
      for (var index = 1; index < ranking.length; index++) {
        expect((ranking[index - 1].value as num) >= (ranking[index].value as num),
            isTrue);
      }
    }
  });

  test('collection vide et période inversée', () {
    final empty = FlashcardCollectionSnapshot(version: 0, cards: []);
    final result = useCase.calculate(empty);
    expect(result.totalWords, 0);
    expect(result.totalPairs, 0);
    expect(result.dailySeries, isEmpty);
    expect(result.dailyAverage, 0);
    expect(
      () => useCase.calculate(empty,
          startDate: DateTime(2026, 1, 2), endDate: DateTime(2026, 1, 1)),
      throwsArgumentError,
    );
  });

  test('conserve la période choisie quand le snapshot partagé change', () async {
    final firstDay = DateTime(2026, 1, 1);
    final secondDay = DateTime(2026, 1, 2);
    final controller = StreamController<FlashcardCollectionSnapshot>();
    final container = ProviderContainer(overrides: [
      flashcardCollectionProvider.overrideWith((ref) => controller.stream),
      statsClockProvider.overrideWithValue(() => DateTime(2026, 1, 3)),
    ]);
    final firstResult = Completer<StatsViewData>();
    final secondResult = Completer<StatsViewData>();
    final subscription = container.listen(statsViewDataProvider, (_, next) {
      if (!next.hasValue) return;
      final value = next.requireValue;
      if (value.statistics.version == 1 && !firstResult.isCompleted) {
        firstResult.complete(value);
      }
      if (value.statistics.version == 2 && !secondResult.isCompleted) {
        secondResult.complete(value);
      }
    });
    addTearDown(() async {
      subscription.close();
      container.dispose();
      await controller.close();
    });

    final firstPair = [
      _card(1, 'bonjour', 'hello', 'FR', 'EN', firstDay, 0),
      _card(2, 'hello', 'bonjour', 'EN', 'FR', firstDay, 0),
    ];
    controller.add(FlashcardCollectionSnapshot(version: 1, cards: firstPair));
    expect((await firstResult.future).statistics.totalWords, 1);

    container.read(statsViewModelProvider.notifier).updateStartDate(secondDay);
    controller.add(FlashcardCollectionSnapshot(version: 2, cards: [
      ...firstPair,
      _card(3, 'salut', 'hi', 'FR', 'EN', secondDay, 0),
      _card(4, 'hi', 'salut', 'EN', 'FR', secondDay, 0),
    ]));
    final updated = await secondResult.future;
    expect(updated.startDate, secondDay);
    expect(updated.statistics.totalWords, 1);
    expect(updated.statistics.dailySeries.single.date, secondDay);
  });
}
