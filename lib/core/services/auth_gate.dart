import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../features/authentication/login_page.dart';
import '../../features/home_page.dart';
import '../../features/authentication/email_verification_pending_page.dart';
import 'subscription_service.dart';
import 'consent_manager.dart';

class AuthGate extends StatefulWidget {
  final dynamic flashcardsCollection;
  final dynamic deeplTranslator;

  const AuthGate({
    super.key,
    required this.flashcardsCollection,
    required this.deeplTranslator,
  });

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    ConsentManager.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = snapshot.data;

        if (user != null && user.emailVerified) {
          return FutureBuilder<bool>(
            future: SubscriptionService().isUserSubscribed(user.uid),
            builder: (context, subSnapshot) {
              if (subSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              final isSubscribed = subSnapshot.data ?? false;
              return HomePage(
                flashcardsCollection: widget.flashcardsCollection,
                deeplTranslator: widget.deeplTranslator,
                isSubscribed: isSubscribed,
              );
            },
          );
        } else if (user != null && !user.emailVerified) {
          return const EmailVerificationPendingPage();
        }

        return const LoginPage();
      },
    );
  }
}
