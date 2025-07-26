import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../l10n/app_localizations.dart';

class EmailVerificationPendingPage extends StatefulWidget {
  const EmailVerificationPendingPage({super.key});

  @override
  State<EmailVerificationPendingPage> createState() => _EmailVerificationPendingPageState();
}

class _EmailVerificationPendingPageState extends State<EmailVerificationPendingPage> {
  bool isSending = false;
  bool isChecking = false;
  String? message;

  Future<void> resendVerificationEmail() async {
    setState(() {
      isSending = true;
      message = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser!;
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
      final user = FirebaseAuth.instance.currentUser!;
      await user.reload(); // Important : recharge l’état depuis Firebase
      final refreshedUser = FirebaseAuth.instance.currentUser;

      if (refreshedUser!.emailVerified) {
        if (mounted) {
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
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? AppLocalizations.of(context)!.yourEmail;

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
              onPressed: () => FirebaseAuth.instance.signOut(),
              child: Text(AppLocalizations.of(context)!.logOut),
            ),
          ],
        ),
      ),
    );
  }
}
