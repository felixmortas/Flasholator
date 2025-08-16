enum TimeGranularity { daily, weekly, monthly, yearly }

class LanguagePair {
  final String source;
  final String target;

  LanguagePair(this.source, this.target);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LanguagePair &&
          ((source == other.source && target == other.target) ||
              (source == other.target && target == other.source));

  @override
  int get hashCode => source.hashCode ^ target.hashCode;
}

class TimeSeriesData {
  final DateTime date;
  final int count;

  TimeSeriesData(this.date, this.count);
}

class StatsData {
  final int totalWords;
  final int totalPairs;
  final num dailyAverage;
  final num weeklyAverage;
  final num monthlyAverage;
  final num yearlyAverage;
  final List<TimeSeriesData> dailySeries;
  final List<RankingItem> mostReviewed;
  final List<RankingItem> mostSuccessful;
  final List<RankingItem> easiest;

  StatsData({
    required this.totalWords,
    required this.totalPairs,
    required this.dailyAverage,
    required this.weeklyAverage,
    required this.monthlyAverage,
    required this.yearlyAverage,
    required this.dailySeries,
    required this.mostReviewed,
    required this.mostSuccessful,
    required this.easiest,
  });
}

extension StatsDataAggregation on StatsData {
  List<TimeSeriesData> aggregate(TimeGranularity granularity) {
    final Map<String, int> aggregated = {};

    for (var item in dailySeries) {
      DateTime date = item.date;
      late String key;

      switch (granularity) {
        case TimeGranularity.daily:
          key = date.toIso8601String().substring(0, 10); // yyyy-MM-dd
          break;
        case TimeGranularity.weekly:
          final weekYear = _getWeekYear(date);
          key = '${weekYear[0]}-W${weekYear[1]}';
          break;
        case TimeGranularity.monthly:
          key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
          break;
        case TimeGranularity.yearly:
          key = '${date.year}';
          break;
      }

      aggregated[key] = (aggregated[key] ?? 0) + item.count;
    }

    // Convert to TimeSeriesData
    return aggregated.entries.map((entry) {
      late DateTime date;
      switch (granularity) {
        case TimeGranularity.daily:
          date = DateTime.parse(entry.key);
          break;
        case TimeGranularity.weekly:
          final parts = entry.key.split('-W');
          date = _getFirstDayOfWeek(int.parse(parts[0]), int.parse(parts[1]));
          break;
        case TimeGranularity.monthly:
          final parts = entry.key.split('-');
          date = DateTime(int.parse(parts[0]), int.parse(parts[1]), 1);
          break;
        case TimeGranularity.yearly:
          date = DateTime(int.parse(entry.key), 1, 1);
          break;
      }
      return TimeSeriesData(date, entry.value);
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  // Helper to get ISO week number and year
  List<int> _getWeekYear(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    final firstDay = DateTime(monday.year, 1, 1);
    final week =
        ((monday.difference(firstDay).inDays + firstDay.weekday) / 7).ceil();
    return [monday.year, week];
  }

  DateTime _getFirstDayOfWeek(int year, int week) {
    final firstDay = DateTime(year, 1, 1);
    final daysToAdd = (week - 1) * 7 - (firstDay.weekday - 1);
    return firstDay.add(Duration(days: daysToAdd));
  }
}

class RankingItem {
  final String word;
  final dynamic value;
  final String languagePair;

  RankingItem(this.word, this.value, this.languagePair);
}
