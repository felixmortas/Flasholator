import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flasholator/features/authentication/login_page.dart';
import 'package:flasholator/features/home_page.dart';
import 'package:flasholator/features/authentication/email_verification_pending_page.dart';
import 'package:flasholator/core/services/consent_manager.dart';
import 'package:flasholator/core/providers/firebase_auth_provider.dart';

class AuthGate extends ConsumerStatefulWidget {

  const AuthGate({
    super.key,
  });

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();

}

class _AuthGateState extends ConsumerState<AuthGate> {
  @override
  void initState() {
    super.initState();
    ConsentManager.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final firebaseAuth = ref.watch(firebaseAuthProvider);

    return StreamBuilder<User?>(
      stream: firebaseAuth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = snapshot.data;

        if (user != null && user.emailVerified) {
          return const HomePage();
        } else if (user != null && !user.emailVerified) {
          return const EmailVerificationPendingPage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
