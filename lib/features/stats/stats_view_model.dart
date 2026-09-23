import 'package:flasholator/features/flashcards/application/flashcard_collection_projections.dart';
import 'package:flasholator/features/flashcards/flashcard_providers.dart';
import 'package:flasholator/features/stats/statistics_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class StatsPeriodState {
  const StatsPeriodState({required this.startDate, required this.endDate});

  final DateTime? startDate;
  final DateTime endDate;
}

final class StatsViewData {
  const StatsViewData({
    required this.startDate,
    required this.endDate,
    required this.statistics,
  });

  final DateTime startDate;
  final DateTime endDate;
  final FlashcardStatisticsProjection statistics;
}

final class StatsViewModel extends StateNotifier<StatsPeriodState> {
  StatsViewModel(DateTime today)
      : super(StatsPeriodState(startDate: null, endDate: today));

  void updateStartDate(DateTime date) {
    if (date.isAfter(state.endDate)) return;
    state = StatsPeriodState(startDate: date, endDate: state.endDate);
  }

  void updateEndDate(DateTime date, {required DateTime currentStartDate}) {
    if (date.isBefore(currentStartDate)) return;
    state = StatsPeriodState(startDate: state.startDate, endDate: date);
  }
}

final statsClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final statisticsUseCaseProvider =
    Provider<StatisticsUseCase>((ref) => const StatisticsUseCase());

final statsViewModelProvider =
    StateNotifierProvider.autoDispose<StatsViewModel, StatsPeriodState>((ref) {
  return StatsViewModel(ref.watch(statsClockProvider)());
});

final statsViewDataProvider = Provider.autoDispose<AsyncValue<StatsViewData>>((ref) {
  final period = ref.watch(statsViewModelProvider);
  final useCase = ref.watch(statisticsUseCaseProvider);
  return ref.watch(flashcardCollectionProvider).whenData((snapshot) {
    final all = useCase.calculate(snapshot);
    final firstDate = all.dailySeries.isEmpty ? null : all.dailySeries.first.date;
    final startDate = period.startDate ??
        (firstDate == null || firstDate.isAfter(period.endDate)
            ? period.endDate.subtract(const Duration(days: 30))
            : firstDate);
    return StatsViewData(
      startDate: startDate,
      endDate: period.endDate,
      statistics: useCase.calculate(
        snapshot,
        startDate: startDate,
        endDate: period.endDate,
      ),
    );
  });
});
