import 'package:flutter/material.dart';
import '../../../core/models/stats_model.dart';

class RankingSection extends StatelessWidget {
  final StatsData data;

  const RankingSection({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRankingCard('Plus révisés', data.mostReviewed),
        const SizedBox(height: 16),
        _buildRankingCard('Succès consécutifs', data.mostSuccessful),
        const SizedBox(height: 16),
        _buildRankingCard('Mots les plus faciles', data.easiest),
      ],
    );
  }

  Widget _buildRankingCard(String title, List<RankingItem> items) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(2),
              },
              children: [
                const TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text('Mot',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text('Valeur',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text('Langues',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                ...items.map((item) => TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(item.word),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(item.value.toString()),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(item.languagePair),
                        ),
                      ],
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
