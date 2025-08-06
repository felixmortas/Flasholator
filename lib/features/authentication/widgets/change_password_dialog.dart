import 'package:flutter/material.dart';

import 'package:flasholator/l10n/app_localizations.dart';

class ChangePasswordDialog extends StatefulWidget {
  final Function(String currentPassword, String newPassword) onConfirm;

  const ChangePasswordDialog({super.key, required this.onConfirm});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _error;

  void _validateAndSubmit() {
    final current = _currentPasswordController.text;
    final newPass = _newPasswordController.text;
    final confirm = _confirmPasswordController.text;

    if (newPass != confirm) {
      setState(() => _error = AppLocalizations.of(context)!.passwordsDoNotMatch);
      return;
    }

    if (newPass.length < 6) {
      setState(() => _error = AppLocalizations.of(context)!.passwordRequirements);
      return;
    }

    widget.onConfirm(current, newPass);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.changePassword),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_error != null)
            Text(_error!, style: const TextStyle(color: Colors.red)),
          TextField(
            controller: _currentPasswordController,
            obscureText: true,
            decoration: InputDecoration(labelText: AppLocalizations.of(context)!.currentPassword),
          ),
          TextField(
            controller: _newPasswordController,
            obscureText: true,
            decoration: InputDecoration(labelText: AppLocalizations.of(context)!.newPassword),
          ),
          TextField(
            controller: _confirmPasswordController,
            obscureText: true,
            decoration: InputDecoration(labelText: AppLocalizations.of(context)!.confirmPassword),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: _validateAndSubmit,
          child: Text(AppLocalizations.of(context)!.confirm),
        ),
      ],
    );
  }
}
