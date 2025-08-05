import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../features/authentication/login_page.dart';
import '../../features/home_page.dart';
import '../../features/authentication/email_verification_pending_page.dart';
import 'subscription_service.dart';
import 'consent_manager.dart';
import 'user_preferences_service.dart';

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
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = authSnapshot.data;

        if (user != null && user.emailVerified) {
          return FutureBuilder<bool>(
            future: UserPreferencesService.isUserDataCached(),
            builder: (context, isCachedSnapshot) {
              if (isCachedSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              final isCached = isCachedSnapshot.data ?? false;

              if (isCached) {
                return HomePage(
                  flashcardsCollection: widget.flashcardsCollection,
                  deeplTranslator: widget.deeplTranslator,
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
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        try {
          final now = DateTime.now();
          final dateStr = DateFormat('yyyy-MM-dd').format(now);
          
          final Map<String, dynamic> newUserData = {
            'isSubscribed': false,
            'subscriptionDate': dateStr,
            'subscriptionEndDate': null,
            'canTranslate': true,
          };

          await FirebaseFirestore.instance.collection('users').doc(user.uid).set(newUserData);
          await UserPreferencesService.saveUserFieldsLocally(newUserData);

        } catch (e) {
          return const Scaffold(body: Center(child: Text('Profil utilisateur non trouvé.')));
        }
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final updatedUserData = await SubscriptionService.handleUserStatus(user.uid, userData);
      await UserPreferencesService.saveUserFieldsLocally(updatedUserData);

      return HomePage(
        flashcardsCollection: widget.flashcardsCollection,
        deeplTranslator: widget.deeplTranslator,
        user: user,
      );
    } catch (e) {
      return Scaffold(
        body: Center(child: Text('Erreur lors du chargement des données utilisateur : $e')),
      );
    }
  }
}
