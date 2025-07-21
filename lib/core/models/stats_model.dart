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
  final double dailyAverage;
  final double weeklyAverage;
  final double monthlyAverage;
  final double yearlyAverage;
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

class RankingItem {
  final String word;
  final dynamic value;
  final String languagePair;

  RankingItem(this.word, this.value, this.languagePair);
}
