import 'package:flasholator/core/models/stats_model.dart';
import 'package:flasholator/features/stats/stats_view_model.dart';
import 'package:flasholator/features/stats/widgets/date_time_picker.dart';
import 'package:flasholator/features/stats/widgets/ranking_section.dart';
import 'package:flasholator/features/stats/widgets/summary_section.dart';
import 'package:flasholator/features/stats/widgets/time_series_chart.dart';
import 'package:flasholator/l10n/app_localizations.dart';
import 'package:flasholator/style/grid_background_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(statsViewDataProvider);
    return GridBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.statistics)),
        body: result.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text('${AppLocalizations.of(context)!.error}: $error'),
          ),
          data: (viewData) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: DateRangePickerRow(
                  startDate: viewData.startDate,
                  endDate: viewData.endDate,
                  onStartDateChanged: ref
                      .read(statsViewModelProvider.notifier)
                      .updateStartDate,
                  onEndDateChanged: (date) => ref
                      .read(statsViewModelProvider.notifier)
                      .updateEndDate(date,
                          currentStartDate: viewData.startDate),
                ),
              ),
              Expanded(child: _StatsView(data: viewData.statistics.data)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsView extends StatelessWidget {
  const _StatsView({required this.data});

  final StatsData data;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SummarySection(data: data),
          const SizedBox(height: 24),
          TimeSeriesChart(data: data),
          const SizedBox(height: 24),
          RankingSection(data: data),
        ],
      ),
    );
  }
}
