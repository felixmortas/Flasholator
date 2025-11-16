import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flasholator/l10n/app_localizations.dart';
import 'package:flasholator/core/providers/user_manager_provider.dart';
import 'package:flasholator/style/grid_background_painter.dart';

class EmailVerificationPendingPage extends ConsumerStatefulWidget {
  const EmailVerificationPendingPage({super.key});

  @override
  ConsumerState<EmailVerificationPendingPage> createState() => _EmailVerificationPendingPageState();
}

class _EmailVerificationPendingPageState extends ConsumerState<EmailVerificationPendingPage> {
  bool isSending = false;
  bool isChecking = false;
  String? message;

  Future<void> resendVerificationEmail() async {
    setState(() {
      isSending = true;
      message = null;
    });

    try {
      final userManager = ref.read(userManagerProvider);
      await userManager.sendEmailVerification();

      setState(() => message = AppLocalizations.of(context)!.verificationEmailSent);
    } catch (e) {
      setState(() => message = AppLocalizations.of(context)!.error);
    } finally {
      setState(() => isSending = false);
    }
  }

  Future<void> checkVerificationStatus() async {
    setState(() {
      isChecking = true;
      message = null;
    });

    try {
      final userManager = ref.read(userManagerProvider);

      if (await userManager.isEmailVerified()) {
        if (mounted) {
          await userManager.updateUser({'canTranslate': true});
          Navigator.pushReplacementNamed(context, "/");
        }
      } else {
        setState(() => message = AppLocalizations.of(context)!.yourAddressHasNotYetBeenVerified);
      }
    } catch (e) {
      setState(() => message = AppLocalizations.of(context)!.error);
    } finally {
      setState(() => isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userManager = ref.read(userManagerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.emailVerification)),
      body: GridBackground(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(AppLocalizations.of(context)!.aVerificationEmailHasBeenSentTo,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(userManager.getUserEmail(),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  if (message != null)
                    Text(
                      message!,
                      style: TextStyle(
                        color: message!.contains(AppLocalizations.of(context)!.error) ? Colors.red : Colors.green,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isSending ? null : resendVerificationEmail,
                    child: isSending
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(AppLocalizations.of(context)!.resendEmail),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: isChecking ? null : checkVerificationStatus,
                    child: isChecking
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(AppLocalizations.of(context)!.iHaveConfirmedMyEmail),
                  ),
                  const SizedBox(height: 30),
                  TextButton(
                    onPressed: () => userManager.signOut(),
                    child: Text(AppLocalizations.of(context)!.logOut),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}