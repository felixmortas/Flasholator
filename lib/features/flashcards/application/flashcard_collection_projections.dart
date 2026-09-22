import 'package:flasholator/core/models/stats_model.dart';
import 'package:flasholator/features/flashcards/domain/flashcard_collection.dart';
import 'package:flasholator/features/flashcards/domain/flashcard_pair.dart';

final class FlashcardReviewProjection {
  FlashcardReviewProjection({required this.version, required Iterable<PersistedFlashcard> cards})
      : cards = List.unmodifiable(cards);
  final int version;
  final List<PersistedFlashcard> cards;
}

final class FlashcardTablePair {
  const FlashcardTablePair({required this.key, required this.card});
  final FlashcardPairKey key;
  final PersistedFlashcard card;
}

final class FlashcardTableProjection {
  FlashcardTableProjection({required this.version, required Iterable<FlashcardTablePair> pairs})
      : pairs = List.unmodifiable(pairs);
  final int version;
  final List<FlashcardTablePair> pairs;
}

final class FlashcardStatisticsProjection {
  const FlashcardStatisticsProjection({required this.version, required this.data});

  final int version;
  final StatsData data;

  int get totalWords => data.totalWords;
  int get totalPairs => data.totalPairs;
  num get dailyAverage => data.dailyAverage;
  num get weeklyAverage => data.weeklyAverage;
  num get monthlyAverage => data.monthlyAverage;
  num get yearlyAverage => data.yearlyAverage;
  List<TimeSeriesData> get dailySeries => data.dailySeries;
  List<RankingItem> get mostReviewed => data.mostReviewed;
  List<RankingItem> get mostSuccessful => data.mostSuccessful;
  List<RankingItem> get easiest => data.easiest;
}

/// Projections pures : aucune lecture Drift, aucune mutation du snapshot.
final class FlashcardCollectionProjections {
  const FlashcardCollectionProjections._();

  static FlashcardReviewProjection review(FlashcardCollectionSnapshot snapshot, {required DateTime now}) =>
      FlashcardReviewProjection(
        version: snapshot.version,
        cards: snapshot.cards.where((card) => card.nextReviewDate == null || !now.isBefore(card.nextReviewDate!)),
      );

  static FlashcardTableProjection table(FlashcardCollectionSnapshot snapshot) {
    final pairs = _selectedPairs(snapshot)
        .map((pair) => FlashcardTablePair(key: pair.key, card: pair.cards.first))
        .toList(growable: false);
    return FlashcardTableProjection(version: snapshot.version, pairs: pairs);
  }

  static FlashcardStatisticsProjection statistics(FlashcardCollectionSnapshot snapshot) {
    final pairs = _selectedPairs(snapshot);
    final cards = pairs.expand((pair) => pair.cards).toList(growable: false);
    final languages = <LanguagePair>{for (final card in cards) LanguagePair(card.sourceLang, card.targetLang)};
    final counts = <DateTime, int>{};
    for (final pair in pairs) {
      final date = _dayOf(pair.cards.reduce(
        (earliest, card) => card.addedDate.isBefore(earliest.addedDate) ? card : earliest,
      ).addedDate);
      counts[date] = (counts[date] ?? 0) + 1;
    }
    final series = counts.entries.map((entry) => TimeSeriesData(entry.key, entry.value)).toList()
      ..sort((left, right) => left.date.compareTo(right.date));
    final totalWords = pairs.length;
    final averages = _averages(totalWords, series);
    return FlashcardStatisticsProjection(
      version: snapshot.version,
      data: StatsData(
        totalWords: totalWords, totalPairs: languages.length,
        dailyAverage: averages.$1, weeklyAverage: averages.$2,
        monthlyAverage: averages.$3, yearlyAverage: averages.$4,
        dailySeries: series,
        mostReviewed: _ranking(cards, (card) => card.timesReviewed),
        mostSuccessful: _ranking(cards, (card) => card.repetitions),
        easiest: _ranking(cards, (card) => card.easiness),
      ),
    );
  }

  static bool _isReciprocalPair(PersistedFlashcard first, PersistedFlashcard second) {
    final values = [
      first.front,
      first.back,
      first.sourceLang,
      first.targetLang,
      second.front,
      second.back,
      second.sourceLang,
      second.targetLang,
    ];
    return values.every((value) => value.trim().isNotEmpty) &&
        first.front == second.back && first.back == second.front &&
        first.sourceLang == second.targetLang && first.targetLang == second.sourceLang;
  }

  /// Une seule paire complète est retenue par clé canonique. Les lignes legacy
  /// surnuméraires ou malformées restent intactes dans le snapshot.
  static List<_SelectedPair> _selectedPairs(FlashcardCollectionSnapshot snapshot) {
    final grouped = <FlashcardPairKey, List<PersistedFlashcard>>{};
    for (final card in snapshot.cards) {
      final key = FlashcardPairKey.fromValues(
        front: card.front,
        back: card.back,
        sourceLang: card.sourceLang,
        targetLang: card.targetLang,
      );
      (grouped[key] ??= []).add(card);
    }
    final selected = <_SelectedPair>[];
    for (final entry in grouped.entries) {
      final cards = [...entry.value]..sort((left, right) => left.id.compareTo(right.id));
      for (var index = 0; index < cards.length; index++) {
        final first = cards[index];
        for (var candidate = index + 1; candidate < cards.length; candidate++) {
          final second = cards[candidate];
          if (_isReciprocalPair(first, second)) {
            selected.add(_SelectedPair(entry.key, [first, second]));
            break;
          }
        }
        if (selected.isNotEmpty && selected.last.key == entry.key) break;
      }
    }
    return selected;
  }

  static DateTime _dayOf(DateTime date) => DateTime(date.year, date.month, date.day);

  static (num, num, num, num) _averages(int totalWords, List<TimeSeriesData> series) {
    if (series.isEmpty) return (0, 0, 0, 0);
    final totalDays = series.last.date.difference(series.first.date).inDays + 1;
    return (
      totalWords / totalDays,
      totalDays >= 7 ? totalWords / (totalDays / 7) : totalWords,
      totalDays >= 30 ? totalWords / (totalDays / 30) : totalWords,
      totalDays >= 365 ? totalWords / (totalDays / 365) : totalWords,
    );
  }

  static List<RankingItem> _ranking(List<PersistedFlashcard> cards, num Function(PersistedFlashcard) value) {
    final ranked = [...cards]..sort((left, right) => value(right).compareTo(value(left)));
    return ranked.take(5).map((card) => RankingItem(card.front, value(card), '${card.sourceLang}-${card.targetLang}')).toList(growable: false);
  }
}

final class _SelectedPair {
  const _SelectedPair(this.key, this.cards);

  final FlashcardPairKey key;
  final List<PersistedFlashcard> cards;
}
