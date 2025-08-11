import 'package:flutter/material.dart';

import 'package:flasholator/l10n/app_localizations.dart';
import 'package:flasholator/features/stats/stats_page.dart';

class SettingsDialog extends StatelessWidget {
  final VoidCallback launchEmail;
  final dynamic flashcardsCollection; // remplace "dynamic" par ton type exact

  const SettingsDialog({
    Key? key,
    required this.launchEmail,
    required this.flashcardsCollection,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(loc.settings),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              launchEmail();
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 5,
            ),
            child: Row(
              children: [
                const Icon(Icons.feedback, size: 18),
                const SizedBox(width: 8),
                Text(loc.giveAFeedback),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      StatsPage(flashcardsCollection: flashcardsCollection),
                ),
              );
            },
            child: Text(loc.statistics),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/help');
            },
            child: Text(loc.help),
          ),
        ],
      ),
    );
  }
}
