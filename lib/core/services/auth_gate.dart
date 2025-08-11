import 'package:flasholator/core/providers/user_manager_provider.dart';
import 'package:flasholator/core/providers/user_sync_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flasholator/features/authentication/login_page.dart';
import 'package:flasholator/features/home_page.dart';
import 'package:flasholator/features/authentication/email_verification_pending_page.dart';

class AuthGate extends ConsumerStatefulWidget {

  const AuthGate({
    super.key,
  });

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {

  @override
  Widget build(BuildContext context) {
    final userManager = ref.watch(userManagerProvider);
    final userSyncState = ref.watch(userSyncStateProvider);
    
    return StreamBuilder<User?>(
      stream: userManager.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || !userSyncState) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = snapshot.data;
        
        if (user != null && user.emailVerified && userSyncState) {
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
