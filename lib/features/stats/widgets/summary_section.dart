import 'package:flutter/material.dart';
import '../../../core/models/stats_model.dart';

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
            _buildSummaryItem('Mots ajoutés', data.totalWords),
            _buildSummaryItem('Paires de langues', data.totalPairs),
            _buildSummaryItem(
                'Moyenne/jour', data.dailyAverage.toStringAsFixed(2)),
            _buildSummaryItem(
                'Moyenne/semaine', data.weeklyAverage.toStringAsFixed(2)),
            _buildSummaryItem(
                'Moyenne/mois', data.monthlyAverage.toStringAsFixed(2)),
            _buildSummaryItem(
                'Moyenne/an', data.yearlyAverage.toStringAsFixed(2)),
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
