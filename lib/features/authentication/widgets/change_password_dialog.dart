import 'package:flutter/material.dart';

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
      setState(() => _error = "Les mots de passe ne correspondent pas.");
      return;
    }

    if (newPass.length < 6) {
      setState(() => _error = "Le mot de passe doit contenir au moins 6 caractères.");
      return;
    }

    widget.onConfirm(current, newPass);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Changer le mot de passe'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_error != null)
            Text(_error!, style: const TextStyle(color: Colors.red)),
          TextField(
            controller: _currentPasswordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Mot de passe actuel'),
          ),
          TextField(
            controller: _newPasswordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Nouveau mot de passe'),
          ),
          TextField(
            controller: _confirmPasswordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Confirmer le mot de passe'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _validateAndSubmit,
          child: const Text('Confirmer'),
        ),
      ],
    );
  }
}
