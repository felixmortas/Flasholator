import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'widgets/unsubscribe_dialog.dart';
import 'widgets/review_section.dart';

class UnsubscribePage extends StatelessWidget {
  final VoidCallback onUnsubscribe;

  const UnsubscribePage({Key? key, required this.onUnsubscribe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.unsubscribeAction),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.reconsiderMessage,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                AppLocalizations.of(context)!.premiumBenefits,
              ),
              const SizedBox(height: 10),
              Text(
                '- ${AppLocalizations.of(context)!.benefit1}\n'
                '- ${AppLocalizations.of(context)!.benefit2}\n'
                '- ${AppLocalizations.of(context)!.benefit3}\n'
                '- ${AppLocalizations.of(context)!.benefit4}\n'
                '- ${AppLocalizations.of(context)!.benefit5}\n'
                '- ${AppLocalizations.of(context)!.benefit6}\n'
                '- ${AppLocalizations.of(context)!.benefit7}'
              ),
              const SizedBox(height: 10),
              const ReviewsSection(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                    return UnsubscribeDialog(
                      onUnsubscribe: () {
                        onUnsubscribe();
                        Navigator.pop(context); 
                      },
                    );
                    },
                  );
                },
                child: Text(AppLocalizations.of(context)!.unsubscribe),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
