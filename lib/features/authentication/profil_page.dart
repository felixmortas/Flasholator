import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'widgets/change_password_dialog.dart';
import '../../core/services/subscription_service.dart';
import '../../l10n/app_localizations.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}


class _ProfilePageState extends State<ProfilePage> {
  late Future<DocumentSnapshot> _subscriptionFuture;

  @override
  void initState() {
    super.initState();
    _subscriptionFuture = _loadSubscription();
  }

  Future<void> _handleSubscriptionAction({
    required bool isSubscribed,
    required Map<String, dynamic>? subscriptionData,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final service = SubscriptionService();
    final now = DateTime.now();

    if (!isSubscribed) {
      await service.markUserAsSubscribed(uid);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.subscriptionActivated)),
      );
    } else {
      final rawEndDate = subscriptionData?['subscriptionEndDate'];

      // S'il y a une date de fin future → proposer résiliation
      if (rawEndDate == null || DateTime.tryParse(rawEndDate)?.isAfter(now) == true) {
        final confirm = await _showConfirmationDialog(
          context,
          title: AppLocalizations.of(context)!.cancelSubscription,
          content:
              AppLocalizations.of(context)!.confirmCancelSubscription,
        );
        if (confirm) {
          final endDate = now.add(const Duration(days: 30));
          await service.cancelSubscription(uid, endDate);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$AppLocalizations.of(context)!.subscriptionCancelled + ${_formatDate(endDate)}')),
          );
        }
      } else {
        // Abonnement expiré → réactivation
        await service.markUserAsSubscribed(uid);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.subscriptionReactivated)),
        );
      }
    }

    _refreshSubscription();
  }


  Future<DocumentSnapshot> _loadSubscription() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception(AppLocalizations.of(context)!.userNotConnected);
    return FirebaseFirestore.instance.collection('subscribedUsers').doc(uid).get();
  }

  void _refreshSubscription() {
    setState(() {
      _subscriptionFuture = _loadSubscription();
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }


  String _formatDateString(String dateString) {
    final date = DateTime.tryParse(dateString);
    if (date == null) return AppLocalizations.of(context)!.invalidDate;
    return _formatDate(date);
  }

  Future<void> _signOut(BuildContext context) async {
    final confirmed = await _showConfirmationDialog(
      context,
      title: AppLocalizations.of(context)!.logOut,
      content: AppLocalizations.of(context)!.confirmLogout,
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
            SnackBar(content: Text(AppLocalizations.of(context)!.passwordUpdated)),
          );
        } on FirebaseAuthException catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${AppLocalizations.of(context)!.error} + ${e.message}')),
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
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text(AppLocalizations.of(context)!.cancel)),
              TextButton(onPressed: () => Navigator.pop(context, true), child: Text(AppLocalizations.of(context)!.confirm)),
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
            title: Text(AppLocalizations.of(context)!.deleteAccount),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(AppLocalizations.of(context)!.confirmDeleteAccount),
                TextField(
                  controller: controller,
                  obscureText: true,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.password),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text(AppLocalizations.of(context)!.cancel)),
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
                      SnackBar(content: Text(AppLocalizations.of(context)!.incorrectPassword)),
                    );
                  }
                },
                child: Text(AppLocalizations.of(context)!.confirm),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return FutureBuilder<DocumentSnapshot>(
    future: FirebaseFirestore.instance.collection('subscribedUsers').doc(user!.uid).get(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      final isSubscribed = snapshot.hasData && snapshot.data!.exists;
      final subscriptionData = snapshot.data?.data() as Map<String, dynamic>?;

      String abonnementLabel = isSubscribed ? AppLocalizations.of(context)!.premium : AppLocalizations.of(context)!.free;
      String renouvellementLabel = 'N/A';

      if (isSubscribed) {
        final endDate = subscriptionData?['subscriptionEndDate'];
        if (endDate == null) {
          renouvellementLabel = AppLocalizations.of(context)!.autoRenewal;
        } else {
          final date = (endDate as Timestamp).toDate();
          if (date.isAfter(DateTime.now())) {
            renouvellementLabel = '${AppLocalizations.of(context)!.cancelledUntil} + $date';
          } else {
            renouvellementLabel = AppLocalizations.of(context)!.subscriptionExpired;
          }
        }
      }

      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.myProfile)),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRow(AppLocalizations.of(context)!.username, user.displayName ?? AppLocalizations.of(context)!.undefined),
              const SizedBox(height: 16),
              _infoRow(AppLocalizations.of(context)!.password, '********', action: () => _changePassword(context)),
              const Divider(height: 32),
              _infoRow(AppLocalizations.of(context)!.subscription, abonnementLabel),
              _infoRow(AppLocalizations.of(context)!.renewal, renouvellementLabel),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _handleSubscriptionAction(
                  isSubscribed: isSubscribed,
                  subscriptionData: subscriptionData,
                ),
                child: Text(isSubscribed ? AppLocalizations.of(context)!.cancelSubscription : AppLocalizations.of(context)!.activateSubscription),
              ),              
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _signOut(context),
                icon: const Icon(Icons.logout),
                label: Text(AppLocalizations.of(context)!.logOut),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => _deleteAccount(context),
                icon: const Icon(Icons.delete_forever),
                label: Text(AppLocalizations.of(context)!.deleteMyAccount),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          ),
        ),
      );
    },
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
