import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

      setState(() => message = "Email de vérification renvoyé !");
    } catch (e) {
      setState(() => message = "Erreur lors de l'envoi de l'email.");
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
        setState(() => message = "Votre adresse n'est toujours pas vérifiée.");
      }
    } catch (e) {
      setState(() => message = "Erreur lors de la vérification.");
    } finally {
      setState(() => isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? "Votre email";

    return Scaffold(
      appBar: AppBar(title: const Text("Vérification de l'email")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Un email de vérification a été envoyé à :",
                style: Theme.of(context).textTheme.bodyMedium),
            Text(userEmail,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 20),
            if (message != null)
              Text(
                message!,
                style: TextStyle(
                  color: message!.contains("Erreur") ? Colors.red : Colors.green,
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isSending ? null : resendVerificationEmail,
              child: isSending
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text("Renvoyer l'email"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: isChecking ? null : checkVerificationStatus,
              child: isChecking
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text("J'ai confirmé mon email"),
            ),
            const SizedBox(height: 30),
            TextButton(
              onPressed: () => FirebaseAuth.instance.signOut(),
              child: const Text("Se déconnecter"),
            ),
          ],
        ),
      ),
    );
  }
}
