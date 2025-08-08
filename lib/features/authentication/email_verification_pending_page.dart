import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flasholator/l10n/app_localizations.dart';
import 'package:flasholator/core/providers/user_manager_provider.dart';
import 'package:flasholator/core/providers/firebase_auth_provider.dart';

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
      final firebaseAuth = ref.read(firebaseAuthProvider);
      final user = firebaseAuth.currentUser!;
      await user.sendEmailVerification();

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
      final firebaseAuth = ref.read(firebaseAuthProvider);
      final user = firebaseAuth.currentUser!;
      
      await user.reload(); // Important : recharge l’état depuis Firebase
      final refreshedUser = firebaseAuth.currentUser;


      if (refreshedUser!.emailVerified) {
        if (mounted) {
          final userManager = ref.read(userManagerProvider);
          
          final uid = firebaseAuth.currentUser!.uid;
          await userManager.registerUser();
          Navigator.pushReplacementNamed(context, "/"); // Retour vers AuthGate
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
    final firebaseAuth = ref.read(firebaseAuthProvider);
    final userEmail = firebaseAuth.currentUser?.email ?? AppLocalizations.of(context)!.yourEmail;

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.emailVerification)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(AppLocalizations.of(context)!.aVerificationEmailHasBeenSentTo,
                style: Theme.of(context).textTheme.bodyMedium),
            Text(userEmail,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 20),
            if (message != null)
              Text(
                message!,
                style: TextStyle(
                  color: message!.contains(AppLocalizations.of(context)!.error) ? Colors.red : Colors.green,
                ),
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
              onPressed: () => firebaseAuth.signOut(),
              child: Text(AppLocalizations.of(context)!.logOut),
            ),
          ],
        ),
      ),
    );
  }
}
