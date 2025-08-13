import 'package:flasholator/core/models/flashcard.dart';
import 'package:flasholator/core/models/stats_model.dart';
import 'package:flasholator/core/services/flashcards_service.dart';

class StatsService {
  final FlashcardsService flashcardsService;

  StatsService(this.flashcardsService);

  Future<StatsData> calculateStats(
      {DateTime? startDate, DateTime? endDate}) async {
    final flashcards = await flashcardsService.loadAllFlashcards();

    // Filtrage selon la période définie
    final filtered = flashcards.where((fc) {
      final created = DateTime.parse(fc.addedDate);

      if (startDate != null && created.isBefore(startDate)) return false;
      if (endDate != null && created.isAfter(endDate)) return false;
      return true;
    }).toList();

    final pairs = _extractLanguagePairs(filtered);
    final series = _calculateTimeSeries(filtered);
    final averages = _calculateAverages(filtered, series);

    return StatsData(
      totalWords: filtered.length ~/ 2,
      totalPairs: pairs.length,
      dailyAverage: averages['day'] ?? 0,
      weeklyAverage: averages['week'] ?? 0,
      monthlyAverage: averages['month'] ?? 0,
      yearlyAverage: averages['year'] ?? 0,
      dailySeries: series,
      mostReviewed: _getRanking(filtered, 'timesReviewed', 5),
      mostSuccessful: _getRanking(filtered, 'repetitions', 5),
      easiest: _getRanking(filtered, 'easiness', 5),
    );
  }

  Set<LanguagePair> _extractLanguagePairs(List<Flashcard> flashcards) {
    final pairs = <LanguagePair>{};
    for (final card in flashcards) {
      pairs.add(LanguagePair(card.sourceLang, card.targetLang));
    }
    return pairs;
  }

  List<TimeSeriesData> _calculateTimeSeries(List<Flashcard> flashcards) {
    final dailyCount = <DateTime, int>{};

    for (final card in flashcards) {
      try {
        // Parse la date au format "2023-06-28"
        final dateTime = DateTime.parse(card.addedDate);
        // Normalise la date (enlève heures/minutes/secondes)
        final date = DateTime(dateTime.year, dateTime.month, dateTime.day);
        // Compte chaque paire de flashcards (d'où le ~/ 2 plus bas)
        dailyCount[date] = (dailyCount[date] ?? 0) + 1;
      } catch (e) {
        print('Parsing error for card ${card.id}: ${card.addedDate}');
        continue;
      }
    }

    return dailyCount.entries
        .map((e) => TimeSeriesData(
            e.key, e.value ~/ 2)) // Divise par 2 pour compter les paires
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date)); // Trie par date
  }

  Map<String, double> _calculateAverages(
    List<Flashcard> flashcards,
    List<TimeSeriesData> series,
  ) {
    if (series.isEmpty) return {};

    final firstDate = series.first.date;
    final lastDate = series.last.date;
    final totalDays = lastDate.difference(firstDate).inDays + 1;
    final totalWords = flashcards.length ~/ 2;

    return {
      'day': totalWords / totalDays,
      'week': totalWords / (totalDays / 7),
      'month': totalWords / (totalDays / 30),
      'year': totalWords / (totalDays / 365),
    };
  }

  List<RankingItem> _getRanking(
    List<Flashcard> flashcards,
    String field,
    int limit,
  ) {
    flashcards.sort((a, b) {
      final aValue = _getFieldValue(a, field);
      final bValue = _getFieldValue(b, field);
      return bValue.compareTo(aValue);
    });

    return flashcards
        .take(limit)
        .map((card) => RankingItem(
              card.front,
              _getFieldValue(card, field),
              '${card.sourceLang}-${card.targetLang}',
            ))
        .toList();
  }

  dynamic _getFieldValue(Flashcard card, String field) {
    switch (field) {
      case 'timesReviewed':
        return card.timesReviewed;
      case 'repetitions':
        return card.repetitions;
      case 'easiness':
        return card.easiness;
      default:
        return 0;
    }
  }
}
