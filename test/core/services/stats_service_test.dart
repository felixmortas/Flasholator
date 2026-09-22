import 'package:flasholator/core/models/flashcard.dart';
import 'package:flasholator/core/services/stats_service.dart';
import 'package:flutter_test/flutter_test.dart';

Flashcard card(String front, String source, String target, DateTime date,
        {int reviewed = 0, int repetitions = 0, double easiness = 2.5}) =>
    Flashcard(
        front: front,
        back: 'x',
        sourceLang: source,
        targetLang: target,
        addedDate: date,
        timesReviewed: reviewed,
        repetitions: repetitions,
        easiness: easiness);

void main() {
  test(
      'statistics are deterministic, pair languages are unordered and rankings stop at five',
      () async {
    final day = DateTime.utc(2026, 1, 1);
    final cards = <Flashcard>[
      card('a', 'FR', 'EN', day, reviewed: 9),
      card('b', 'EN', 'FR', day, reviewed: 8),
      for (var i = 0; i < 6; i++)
        card('w$i', 'ES', 'DE', day.add(Duration(days: i)),
            reviewed: i, repetitions: i, easiness: 2.5 + i),
    ];
    final stats = await StatsService.test(() async => cards).calculateStats();
    expect(stats.totalWords, 4);
    expect(stats.totalPairs, 2);
    expect(stats.dailySeries.first.count, 1);
    expect(stats.mostReviewed, hasLength(5));
    expect(stats.mostSuccessful, hasLength(5));
    expect(stats.easiest, hasLength(5));
    expect(stats.mostReviewed.first.word, 'a');
  });

  test('empty period returns coherent empty totals and series', () async {
    final stats = await StatsService.test(() async => []).calculateStats();
    expect(stats.totalWords, 0);
    expect(stats.totalPairs, 0);
    expect(stats.dailySeries, isEmpty);
    expect(stats.dailyAverage, 0);
  });
}
