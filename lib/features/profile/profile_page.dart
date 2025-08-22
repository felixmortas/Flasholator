import 'package:flasholator/core/services/flashcards_service.dart';
import 'package:flasholator/features/stats/stats_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flasholator/config/constants.dart';
import 'package:flasholator/features/authentication/widgets/change_password_dialog.dart';
import 'package:flasholator/core/services/user_manager.dart';
import 'package:flasholator/l10n/app_localizations.dart';
import 'package:flasholator/core/services/consent_manager.dart';
import 'package:flasholator/core/providers/user_manager_provider.dart';
import 'package:flasholator/core/providers/user_data_provider.dart';

import 'package:flasholator/features/shared/widgets/subscribe_button.dart';

class ProfilePage extends ConsumerStatefulWidget {

  final FlashcardsService flashcardsService;

  const ProfilePage({
    required this.flashcardsService,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _showPrivacyButton = false;
  late final UserManager userManager;

  @override
  void initState() {
    super.initState();
    userManager = ref.read(userManagerProvider);
    _checkPrivacyOptionsRequirement();
  }

  Future<void> _checkPrivacyOptionsRequirement() async {
    if (!kIsWeb) {
      final required = await ConsentManager.isPrivacyOptionsRequired();
      setState(() {
        _showPrivacyButton = required;
      });
    } else {
      setState(() {
        _showPrivacyButton = false;
      });
    }
  }

  Future<void> _subscribe() async {
    final bool wasSubscribed = ref.read(isSubscribedProvider);
    await userManager.subscribeUser();
    final isSubscribed = ref.read(isSubscribedProvider);

    if (isSubscribed && !wasSubscribed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.subscriptionActivated)),
      );
    } 
  }

  Future<void> _signOut(BuildContext context) async {
    final confirmed = await _showConfirmationDialog(
      context,
      title: AppLocalizations.of(context)!.logOut,
      content: AppLocalizations.of(context)!.confirmLogout,
    );
    if (confirmed) {
      await userManager.signOut();
      Navigator.pop(context); // Ferme la page de profil
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final confirmed = await _showSecureDeletionDialog(context);
    if (!confirmed) return;

    try {
      await userManager.deleteUser();
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
          await userManager.changePassword(currentPassword, newPassword);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.passwordUpdated)),
          );
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
                    await userManager.reauthenticateWithCredential(
                      controller.text
                    );
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

    void _changeEmail(BuildContext context) {
    // TODO: implement email change
  }

  void _toggleNotifications(bool val) {
    // TODO: implement notifications toggle
  }
  
  void _rateApp() {}

  void _openChangelog() {
  }

  void _openMentions() {
  }

  void _openCGV() {
  }

  @override
  Widget build(BuildContext context) {
    final String userName = userManager.getUserName();

    return FutureBuilder<bool>(
      future: userManager.isUserDataCached(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final isSubscribed = ref.watch(isSubscribedProvider);

        return Scaffold(
          appBar: AppBar(title: Text(AppLocalizations.of(context)!.myProfile),
            actions: [
              IconButton(
                icon: const Icon(Icons.help_outline),
                onPressed: () async {
                  final Uri emailLaunchUri = Uri(
                    scheme: 'mailto',
                    path: 'support@tonapp.com',
                    query: 'subject=Support Profil',
                  );
                  if (await canLaunchUrl(emailLaunchUri)) {
                    await launchUrl(emailLaunchUri);
                  }
                },
              ),
            ],
          ),
        
          body: SingleChildScrollView(
          padding: EdgeInsets.all(16 * GOLDEN_NUMBER),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Identité
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    child: Text(
                      userName[0],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(width: 12 * GOLDEN_NUMBER),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userName,
                            style: Theme.of(context).textTheme.titleMedium),
                        Text(
                          "Utilisateur depuis ${userManager.getSignupDate()}",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16 * GOLDEN_NUMBER),

              // CTA Premium
              ElevatedButton(
                onPressed: () {}, // TODO: implémenter partage
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text("Invitez vos proches, obtenez du premium gratuitement"),
              ),
              SizedBox(height: 24 * GOLDEN_NUMBER),

              // Section Stats
              _sectionTitle("Stats"),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => StatsPage(flashcardsService: widget.flashcardsService),
                    ),
                  );
                }, // navigate to stats page
                child: Text("Statistiques"),
              ),
              SizedBox(height: 24 * GOLDEN_NUMBER),

              // Section Mon Compte
              _sectionTitle("Mon Compte"),
              _infoRow("Email", userManager.getUserEmail(),
                  action: () => _changeEmail(context)),
              _infoRow("Mot de passe", "********",
                  action: () => _changePassword(context)),
              SwitchListTile(
                value: true, // ref.watch(notificationsProvider),
                onChanged: (val) => _toggleNotifications(val),
                title: const Text("Notifications cartes à réviser"),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(isSubscribed ? "Abonnement : Abonné" : "Abonnement : Non abonné", style: const TextStyle(fontSize: 16)),
                  ),
                  if (!isSubscribed)
                    SubscribeButton(onPressed: _subscribe)
                ],
              ),
              SizedBox(height: 24 * GOLDEN_NUMBER),

              // Section Social
              _sectionTitle("Social"),
              ListTile(
                leading: const Icon(Icons.star_rate_outlined),
                title: const Text("Noter l’app"),
                onTap: () => _rateApp(),
              ),
              SizedBox(height: 24 * GOLDEN_NUMBER),

              // Section A propos
              _sectionTitle("À propos"),
              _linkTile("Changelog", _openChangelog),
              _linkTile("Mentions légales", _openMentions),
              _linkTile("CGV", _openCGV),
              if(_showPrivacyButton)
                _linkTile("Confidentialité", updateConsent),
              SizedBox(height: 32 * GOLDEN_NUMBER),

              // Logout / Delete
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

// Helpers

Widget _sectionTitle(String text) {
  return Padding(
    padding: EdgeInsets.only(bottom: 8 * GOLDEN_NUMBER),
    child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  );
}

Widget _linkTile(String label, VoidCallback action) {
  return ListTile(
    title: Text(label),
    trailing: const Icon(Icons.chevron_right),
    onTap: action,
  );
}
