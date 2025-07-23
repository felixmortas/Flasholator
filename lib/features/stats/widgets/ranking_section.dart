import '../../../l10n/app_localizations.dart';
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
        _buildRankingCard(context, AppLocalizations.of(context)!.mostReviewed,
            data.mostReviewed),
        const SizedBox(height: 16),
        _buildRankingCard(
            context,
            AppLocalizations.of(context)!.consecutiveSuccesses,
            data.mostSuccessful),
        const SizedBox(height: 16),
        _buildRankingCard(
            context, AppLocalizations.of(context)!.easiestWords, data.easiest),
      ],
    );
  }

  Widget _buildRankingCard(
      BuildContext context, String title, List<RankingItem> items) {
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
                TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(AppLocalizations.of(context)!.word,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(AppLocalizations.of(context)!.value,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(AppLocalizations.of(context)!.languages,
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
