import 'package:flutter/material.dart';

import 'package:flasholator/l10n/app_localizations.dart';
import 'package:flasholator/core/models/stats_model.dart';

class SummarySection extends StatelessWidget {
  final StatsData data;

  const SummarySection({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSummaryItem(
                AppLocalizations.of(context)!.addedWords, data.totalWords),
            _buildSummaryItem(
                AppLocalizations.of(context)!.languagePairs, data.totalPairs),
            _buildSummaryItem(AppLocalizations.of(context)!.averagePerDay,
                data.dailyAverage.toStringAsFixed(2)),
            _buildSummaryItem(AppLocalizations.of(context)!.averagePerWeek,
                data.weeklyAverage.toStringAsFixed(2)),
            _buildSummaryItem(AppLocalizations.of(context)!.averagePerMonth,
                data.monthlyAverage.toStringAsFixed(2)),
            _buildSummaryItem(AppLocalizations.of(context)!.averagePerYear,
                data.yearlyAverage.toStringAsFixed(2)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value.toString(), style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
