import 'package:firebase_auth/firebase_auth.dart';
import 'package:flasholator/core/services/auth_gate.dart';
import 'package:flasholator/core/services/auth_service.dart';
import 'package:flasholator/core/services/user_manager.dart';
import 'package:flasholator/features/authentication/auth_session_repository.dart';
import 'package:flasholator/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _Auth extends Mock implements AuthService {}

class _Manager extends Mock implements UserManager {}

class _Session extends AuthSessionRepository {
  _Session(super.auth, super.manager);

  var retries = 0;
  void show(AuthSessionStatus status) => state = AuthSessionState(status);

  @override
  Future<void> retry() async {
    retries++;
    show(AuthSessionStatus.ready);
  }
}

void main() {
  testWidgets('portal waits, opens ready page and retries an error',
      (tester) async {
    final auth = _Auth();
    when(() => auth.authStateChanges())
        .thenAnswer((_) => const Stream<User?>.empty());
    final session = _Session(auth, _Manager());

    await tester.pumpWidget(ProviderScope(
      overrides: [
        authSessionRepositoryProvider.overrideWith((ref) => session),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AuthGate(readyPage: Text('Accueil prêt')),
      ),
    ));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    session.show(AuthSessionStatus.error);
    await tester.pump();
    expect(find.text('Accueil prêt'), findsNothing);
    await tester.tap(find.byType(TextButton));
    await tester.pump();
    expect(session.retries, 1);
    expect(find.text('Accueil prêt'), findsOneWidget);
  });
}
