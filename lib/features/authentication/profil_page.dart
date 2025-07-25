import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'widgets/change_password_dialog.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _signOut(BuildContext context) async {
    final confirmed = await _showConfirmationDialog(
      context,
      title: 'Déconnexion',
      content: 'Voulez-vous vraiment vous déconnecter ?',
    );
    if (confirmed) {
      await FirebaseAuth.instance.signOut();
      Navigator.pop(context); // Ferme la page de profil
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final confirmed = await _showSecureDeletionDialog(context);
    if (!confirmed) return;

    try {
      await FirebaseAuth.instance.currentUser?.delete();
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : ${e.message}')),
      );
    }
  }

  Future<void> _changePassword(BuildContext context) async {
  showDialog(
    context: context,
    builder: (_) => ChangePasswordDialog(
      onConfirm: (currentPassword, newPassword) async {
        final user = FirebaseAuth.instance.currentUser;

        if (user == null || user.email == null) return;

        try {
          // Re-authentification
          final credential = EmailAuthProvider.credential(
            email: user.email!,
            password: currentPassword,
          );
          await user.reauthenticateWithCredential(credential);

          // Mise à jour du mot de passe
          await user.updatePassword(newPassword);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mot de passe mis à jour avec succès.')),
          );
        } on FirebaseAuthException catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur : ${e.message}')),
          );
        }
      },
    ),
  );
}

  Future<bool> _showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirmer')),
            ],
          ),
        ) ??
        false;
  }

  Future<bool> _showSecureDeletionDialog(BuildContext context) async {
    final controller = TextEditingController();

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Suppression du compte'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Saisissez votre mot de passe pour confirmer la suppression.'),
                TextField(
                  controller: controller,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Mot de passe'),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
              TextButton(
                onPressed: () async {
                  try {
                    final user = FirebaseAuth.instance.currentUser!;
                    final cred = EmailAuthProvider.credential(
                      email: user.email!,
                      password: controller.text,
                    );
                    await user.reauthenticateWithCredential(cred);
                    Navigator.pop(context, true);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Mot de passe incorrect.')),
                    );
                  }
                },
                child: const Text('Confirmer'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Mon Profil')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('Pseudo', user?.displayName ?? 'Non défini'),
            const SizedBox(height: 16),
            _infoRow('Mot de passe', '********', action: () => _changePassword(context)),
            const Divider(height: 32),
            _infoRow('Abonnement', 'Gratuit', action: () {
              // Placeholder - ajouter logique abonnement ici
            }),
            _infoRow('Renouvellement', 'N/A', action: null),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                // Placeholder : annuler / activer abonnement
              },
              child: const Text('Annuler / Activer abonnement'),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () => _signOut(context),
              icon: const Icon(Icons.logout),
              label: const Text('Se déconnecter'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _deleteAccount(context),
              icon: const Icon(Icons.delete_forever),
              label: const Text('Supprimer mon compte'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {VoidCallback? action}) {
    return Row(
      children: [
        Expanded(
          child: Text('$label : $value', style: const TextStyle(fontSize: 16)),
        ),
        if (action != null)
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: action,
          ),
      ],
    );
  }
}
