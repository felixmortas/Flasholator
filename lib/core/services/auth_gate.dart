import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/authentication/login_page.dart';
import '../../features/home_page.dart';
import '../../features/authentication/email_verification_pending_page.dart';

class AuthGate extends StatelessWidget {
  final dynamic flashcardsCollection;
  final dynamic deeplTranslator;

  const AuthGate({
    super.key,
    required this.flashcardsCollection,
    required this.deeplTranslator,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData && snapshot.data!.emailVerified) {
          return HomePage(
            flashcardsCollection: flashcardsCollection,
            deeplTranslator: deeplTranslator,
          );
        } else if (snapshot.hasData && !snapshot.data!.emailVerified) {
          return const EmailVerificationPendingPage();
        }

        return const LoginPage();
      },
    );
  }
}
