import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flasholator/features/authentication/widgets/change_password_dialog.dart';
import 'package:flasholator/core/services/subscription_service.dart';
import 'package:flasholator/l10n/app_localizations.dart';
import 'package:flasholator/features/authentication/unsubscribe_page.dart';
import 'package:flasholator/core/services/consent_manager.dart';
import 'package:flasholator/core/providers/firebase_auth_provider.dart';
import 'package:flasholator/core/providers/subscription_service_provider.dart';
import 'package:flasholator/core/providers/user_data_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {

  const ProfilePage({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}


class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _showPrivacyButton = false;
  late final SubscriptionService subscriptionService;

  @override
  void initState() {
    super.initState();
    subscriptionService = ref.read(subscriptionServiceProvider);
    _initializeUserData();
    _checkPrivacyOptionsRequirement();
  }

  Future<void> _initializeUserData() async {
    // Vérifie si les données sont déjà en cache
    final isCached = await subscriptionService.isUserDataCached();

    if (!isCached) {
      // Récupère depuis Firestore et met à jour le ValueNotifier et SharedPreferences
      await subscriptionService.syncUser();
    }

    // Optionnel : recharge les données depuis le notifier
    // await subscriptionService.getUserFromUserPrefs();

    // Déclenche un rebuild une fois les données prêtes
    setState(() {});
  }


  Future<void> _checkPrivacyOptionsRequirement() async {
    final required = await ConsentManager.isPrivacyOptionsRequired();
    setState(() {
      _showPrivacyButton = required;
    });
  }

  Future<void> _loadSubscriptionFromLocal() async {
    // await subscriptionService.getUserFromNotifier();

    setState(() {}); // déclenche un rebuild pour prendre en compte les nouvelles valeurs
  }

  Future<void> _handleSubscriptionAction() async {
    final now = DateTime.now();
    final userData = await subscriptionService.getUserFromNotifier();

    if (!userData['isSubscribed']) {
      await subscriptionService.subscribeUser();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.subscriptionActivated)),
      );
    } else {
      final rawEndDate = userData['subscriptionEndDate'];
      if (rawEndDate == '' || rawEndDate.isEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UnsubscribePage(
              onUnsubscribe: () async {
                await subscriptionService.scheduleSubscriptionRevocation(
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('${AppLocalizations.of(context)!.subscriptionCancelled} ${_formatDate(now.add(const Duration(days: 30)))}')),
                );
                _loadSubscriptionFromLocal(); // rafraîchir
              },
            ),
          ),
        );
      } else {
        await subscriptionService.subscribeUser();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.subscriptionReactivated)),
        );
      }
    }

    _loadSubscriptionFromLocal(); // rafraîchir les données locales
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _signOut(BuildContext context) async {
    final firebaseAuth = ref.read(firebaseAuthProvider);
    final confirmed = await _showConfirmationDialog(
      context,
      title: AppLocalizations.of(context)!.logOut,
      content: AppLocalizations.of(context)!.confirmLogout,
    );
    if (confirmed) {
      await firebaseAuth.signOut();
      Navigator.pop(context); // Ferme la page de profil
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final confirmed = await _showSecureDeletionDialog(context);
    if (!confirmed) return;

    try {
      final firebaseAuth = ref.read(firebaseAuthProvider);
      await subscriptionService.deleteUser();
      await firebaseAuth.currentUser?.delete();
      Navigator.pop(context);
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context)!.error} ${e.toString()}')),
      );
    }
  }

  Future<void> _changePassword(BuildContext context) async {
  showDialog(
    context: context,
    builder: (_) => ChangePasswordDialog(
      onConfirm: (currentPassword, newPassword) async {
        final firebaseAuth = ref.read(firebaseAuthProvider);
        final user = firebaseAuth.currentUser;

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
        } on Exception catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${AppLocalizations.of(context)!.error} + ${e.toString()}')),
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
                    final firebaseAuth = ref.read(firebaseAuthProvider);
                    final user = firebaseAuth.currentUser!;
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

  void updateConsent() async {
    ConsentForm.showPrivacyOptionsForm((formError) {
      if (formError != null) {
        debugPrint("${formError.errorCode}: ${formError.message}");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(firebaseAuthProvider).currentUser;

    return FutureBuilder<bool>(
      future: subscriptionService.isUserDataCached(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Données utilisateur observées via Riverpod
        final isSubscribed = ref.watch(isSubscribedProvider);
        final endDateStr = ref.watch(subscriptionEndDateProvider);

        final abonnementLabel = isSubscribed
            ? AppLocalizations.of(context)!.premium
            : AppLocalizations.of(context)!.free;

        String renouvellementLabel = '';
        if (isSubscribed) {
          if (endDateStr == '' || endDateStr.isEmpty) {
            renouvellementLabel = AppLocalizations.of(context)!.autoRenewal;
          } else {
            final endDate = DateTime.tryParse(endDateStr);
            renouvellementLabel =
                  '${AppLocalizations.of(context)!.cancelledUntil} ${_formatDate(endDate ?? DateTime.now())})';
          }
        }
        return Scaffold(
          appBar: AppBar(title: Text(AppLocalizations.of(context)!.myProfile)),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow(AppLocalizations.of(context)!.username,
                    user!.displayName ?? AppLocalizations.of(context)!.undefined),
                const SizedBox(height: 16),
                _infoRow(AppLocalizations.of(context)!.password, '********',
                    action: () => _changePassword(context)),
                const Divider(height: 32),
                _infoRow(AppLocalizations.of(context)!.subscription, abonnementLabel),
                _infoRow(AppLocalizations.of(context)!.renewal, renouvellementLabel),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _handleSubscriptionAction(),
                  child: Text((isSubscribed && endDateStr != null && endDateStr != '')
                      ? AppLocalizations.of(context)!.reactivateSubscription
                      : isSubscribed
                          ? AppLocalizations.of(context)!.unsubscribeAction
                          : AppLocalizations.of(context)!.activateSubscription),
                ),
                const SizedBox(height: 12),
                if (_showPrivacyButton)
                  TextButton(
                    onPressed: () => updateConsent(),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size(0, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      alignment: Alignment.centerLeft,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.modifyPrivacyPreferences,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        decoration: TextDecoration.underline,
                      ),
                    ),
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
