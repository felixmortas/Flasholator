import 'package:flutter/material.dart';

import 'package:flasholator/l10n/app_localizations.dart';

// Create custom button activating a methode passed in parameter

class SubscribeButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SubscribeButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.subscriptions),
          const SizedBox(width: 8),
          Text(AppLocalizations.of(context)!.activateSubscription),
        ],
      ),
    );
  }
}
