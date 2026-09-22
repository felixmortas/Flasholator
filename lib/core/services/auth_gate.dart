import 'package:flasholator/features/authentication/auth_session_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flasholator/l10n/app_localizations.dart';

import 'package:flasholator/features/authentication/login_page.dart';
import 'package:flasholator/features/home_page.dart';
import 'package:flasholator/features/authentication/email_verification_pending_page.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key, this.readyPage});

  final Widget? readyPage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionRepositoryProvider);
    switch (session.status) {
      case AuthSessionStatus.loading:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      case AuthSessionStatus.ready:
        return readyPage ?? const HomePage();
      case AuthSessionStatus.verificationPending:
        return const EmailVerificationPendingPage();
      case AuthSessionStatus.signedOut:
        return const LoginPage();
      case AuthSessionStatus.error:
        return Scaffold(
          body: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(AppLocalizations.of(context)!.connectionError),
              TextButton(
                onPressed: () => ref
                    .read(authSessionRepositoryProvider.notifier)
                    .retry().catchError((Object _) {}),
                child: Text(AppLocalizations.of(context)!.again),
              ),
            ]),
          ),
        );
    }
  }
}
