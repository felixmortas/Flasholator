import '../../../l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class CancelDialog extends StatelessWidget {
  // Constructor for CancelAddToCartDialog.
  //
  // The [onCancel] parameter is required and is a callback function
  // that will be executed when the user presses the "Cancel" button.
  const CancelDialog({super.key, required this.onCancel});

  // Callback function to be executed when the user presses the "Cancel" button.
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8.0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: onCancel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows the dialog using a [showDialog] and automatically closes it after 3 seconds
  ///
  /// Uses [Timer] to close the dialog after the time has elapsed
  static void show(BuildContext context, {required VoidCallback onCancel}) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent, // Make the background transparent
      builder: (context) {
        final dialog = CancelDialog(onCancel: onCancel);
        // Use a Timer to close the dialog after 3 seconds.
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.of(context).pop(); // Close the dialog
        });
        return dialog;
      },
    );
  }
}
