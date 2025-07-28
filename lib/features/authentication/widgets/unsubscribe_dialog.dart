import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../l10n/app_localizations.dart';
import '../../../core/services/feedback_service.dart';

class UnsubscribeDialog extends StatefulWidget {
  final VoidCallback onUnsubscribe;

  const UnsubscribeDialog({Key? key, required this.onUnsubscribe}) : super(key: key);

  @override
  _UnsubscribeDialogState createState() => _UnsubscribeDialogState();
}

class _UnsubscribeDialogState extends State<UnsubscribeDialog> {
  String? _selectedReason;
  final TextEditingController _feedbackController = TextEditingController();
  final FeedbackService _feedbackService = FeedbackService();


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.unsubscribe),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(AppLocalizations.of(context)!.sorryToSeeYouGo),
          DropdownButton<String>(
            hint: Text(AppLocalizations.of(context)!.selectReason),
            value: _selectedReason,
            onChanged: (String? newValue) {
              setState(() {
                _selectedReason = newValue;
              });
            },
            items: <String>[
              AppLocalizations.of(context)!.reason1,
              AppLocalizations.of(context)!.reason2,
              AppLocalizations.of(context)!.reason3,
              AppLocalizations.of(context)!.reason4,
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          TextField(
            controller: _feedbackController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.additionalFeedback,
              hintText: AppLocalizations.of(context)!.feedbackPlaceholder,
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        TextButton(
          onPressed: () async {
            // // Uncomment to add feedback to a Firebase database
            // final uid = FirebaseAuth.instance.currentUser?.uid;
            // if (uid != null) {
            //   await _feedbackService.submitFeedback(
            //     uid,
            //     _feedbackController.text,
            //     _selectedReason ?? 'Aucune raison spécifiée',
            //   );
            // }
            widget.onUnsubscribe();
            Navigator.of(context).pop();
          },
          child: Text(AppLocalizations.of(context)!.unsubscribe),
        ),
      ],
    );
  }
}
