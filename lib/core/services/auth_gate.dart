import 'package:flasholator/core/providers/subscription_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flasholator/features/authentication/login_page.dart';
import 'package:flasholator/features/home_page.dart';
import 'package:flasholator/features/authentication/email_verification_pending_page.dart';
import 'package:flasholator/core/services/consent_manager.dart';

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
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = authSnapshot.data;

        if (user != null && user.emailVerified) {
          final subscriptionService = ref.read(subscriptionServiceProvider);

          return FutureBuilder<bool>(
            future: subscriptionService.isUserDataCached(),
            builder: (context, isCachedSnapshot) {
              if (isCachedSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              final isCached = isCachedSnapshot.data ?? false;

              if (isCached) {
                subscriptionService.checkSubscriptionStatus(user.uid);
                return HomePage(
                  user: user,
                );
              } else {
                return FutureBuilder<Widget>(
                  future: _buildUserInitializedHome(user),
                  builder: (context, widgetSnapshot) {
                    if (widgetSnapshot.connectionState == ConnectionState.waiting) {
                      return const Scaffold(body: Center(child: CircularProgressIndicator()));
                    }

                    if (widgetSnapshot.hasError) {
                      return Scaffold(
                        body: Center(child: Text('Une erreur est survenue : ${widgetSnapshot.error}')),
                      );
                    }

                    if (!widgetSnapshot.hasData || widgetSnapshot.data == null) {
                      return const Scaffold(
                        body: Center(child: Text('Aucune donnée disponible')),
                      );
                    }

                    return widgetSnapshot.data!;
                  },
                );
              }
            },
          );
        } else if (user != null && !user.emailVerified) {
          return const EmailVerificationPendingPage();
        }

        return const LoginPage();
      },
    );
  }

  Future<Widget> _buildUserInitializedHome(User user) async {
    final subscriptionService = ref.read(subscriptionServiceProvider);

    try {
      final userDoc = await subscriptionService.getUserFromFirestore(user.uid);

      if (!userDoc.exists) {
        try {          
          await subscriptionService.registerUser(user.uid);
        } catch (e) {
          return const Scaffold(body: Center(child: Text('Profil utilisateur non trouvé.')));
        }
      }

      subscriptionService.checkSubscriptionStatus(user.uid);

      return HomePage(
        user: user,
      );
    } catch (e) {
      return Scaffold(
        body: Center(child: Text('Erreur lors du chargement des données utilisateur : $e')),
      );
    }
  }
}
