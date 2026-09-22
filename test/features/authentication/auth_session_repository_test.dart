import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flasholator/core/services/auth_service.dart';
import 'package:flasholator/core/services/user_manager.dart';
import 'package:flasholator/features/authentication/auth_session_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _Auth extends Mock implements AuthService {}
class _Manager extends Mock implements UserManager {}
class _User extends Mock implements User {}

void main() {
  late _Auth auth;
  late _Manager manager;
  late _User user;
  late StreamController<User?> changes;
  late AuthSessionRepository repository;

  setUp(() {
    auth = _Auth();
    manager = _Manager();
    user = _User();
    changes = StreamController<User?>.broadcast(sync: true);
    when(() => auth.authStateChanges()).thenAnswer((_) => changes.stream);
    when(() => auth.currentUser).thenReturn(user);
    when(() => user.uid).thenReturn('u1');
    when(() => user.email).thenReturn('a@example.com');
    when(() => user.emailVerified).thenReturn(true);
    when(() => manager.initRevenueCat()).thenAnswer((_) async {});
    when(() => manager.syncLocalFromFirestore()).thenAnswer((_) async {});
    when(() => manager.syncNotifierFromCache()).thenAnswer((_) async {});
    repository = AuthSessionRepository(auth, manager);
    addTearDown(() async {
      repository.dispose();
      await changes.close();
    });
  });

  test('restored verified user waits for profile and entitlements', () async {
    final hydration = Completer<void>();
    when(() => manager.syncLocalFromFirestore()).thenAnswer((_) => hydration.future);
    changes.add(user);
    await Future<void>.delayed(Duration.zero);
    expect(repository.session.status, AuthSessionStatus.loading);
    hydration.complete();
    await Future<void>.delayed(Duration.zero);
    expect(repository.session.status, AuthSessionStatus.ready);
    expect(repository.session.account?.uid, 'u1');
    expect(repository.session.account?.email, 'a@example.com');
    when(() => user.email).thenReturn('changed@example.com');
    expect(repository.session.account?.email, 'a@example.com');
    verify(() => manager.initRevenueCat()).called(1);
    verify(() => manager.syncNotifierFromCache()).called(1);
  });

  test('hydration error is recoverable and never exposes ready state', () async {
    when(() => manager.initRevenueCat())
        .thenAnswer((_) async => throw StateError('RevenueCat'));
    changes.add(user);
    await Future<void>.delayed(Duration.zero);
    expect(repository.session.status, AuthSessionStatus.error);
    when(() => manager.initRevenueCat()).thenAnswer((_) async {});
    await repository.retry();
    expect(repository.session.status, AuthSessionStatus.ready);
  });

  test('login keeps Firebase error and does not hydrate', () async {
    changes.add(null);
    when(() => auth.login('a@example.com', 'bad')).thenAnswer((_) async =>
        throw FirebaseAuthException(code: 'invalid-credential'));
    await expectLater(repository.login('a@example.com', 'bad'),
        throwsA(isA<FirebaseAuthException>()));
    expect(repository.session.status, AuthSessionStatus.signedOut);
    verifyNever(() => manager.initRevenueCat());
  });

  test('login hydrates the current uid once when Firebase also emits it', () async {
    when(() => auth.login('a@example.com', 'good'))
        .thenAnswer((_) async => changes.add(user));
    await repository.login('a@example.com', 'good');
    expect(repository.session.status, AuthSessionStatus.ready);
    verify(() => manager.initRevenueCat()).called(1);
    verify(() => manager.syncLocalFromFirestore()).called(1);
  });

  test('verified email hydrates after refresh; unverified stays pending', () async {
    when(() => user.emailVerified).thenReturn(false);
    changes.add(user);
    expect(repository.session.status, AuthSessionStatus.verificationPending);
    when(() => manager.isEmailVerified()).thenAnswer((_) async => false);
    expect(await repository.checkVerification(), isFalse);
    expect(repository.session.status, AuthSessionStatus.verificationPending);
    when(() => manager.isEmailVerified()).thenAnswer((_) async => true);
    when(() => manager.updateUser({'canTranslate': true}))
        .thenAnswer((_) async {});
    when(() => user.emailVerified).thenReturn(true);
    expect(await repository.checkVerification(), isTrue);
    expect(repository.session.status, AuthSessionStatus.ready);
  });

  test('sign out invalidates an in-flight hydration', () async {
    final hydration = Completer<void>();
    when(() => manager.syncLocalFromFirestore()).thenAnswer((_) => hydration.future);
    changes.add(user);
    await Future<void>.delayed(Duration.zero);
    changes.add(null);
    hydration.complete();
    await Future<void>.delayed(Duration.zero);
    expect(repository.session.status, AuthSessionStatus.signedOut);
  });

  test('stream error invalidates hydration and retry succeeds', () async {
    final firstHydration = Completer<void>();
    var calls = 0;
    when(() => manager.syncLocalFromFirestore()).thenAnswer((_) {
      calls++;
      return calls == 1 ? firstHydration.future : Future<void>.value();
    });
    changes.add(user);
    await Future<void>.delayed(Duration.zero);
    changes.addError(StateError('stream failed'));
    expect(repository.session.status, AuthSessionStatus.error);
    await repository.retry();
    expect(repository.session.status, AuthSessionStatus.ready);
    firstHydration.complete();
    await Future<void>.delayed(Duration.zero);
    expect(repository.session.status, AuthSessionStatus.ready);
    verify(() => manager.syncNotifierFromCache()).called(1);
  });

  test('verification result is ignored after account changes', () async {
    final verification = Completer<bool>();
    when(() => user.emailVerified).thenReturn(false);
    when(() => manager.isEmailVerified()).thenAnswer((_) => verification.future);
    changes.add(user);
    final pending = repository.checkVerification();
    when(() => auth.currentUser).thenReturn(null);
    changes.add(null);
    verification.complete(true);
    expect(await pending, isFalse);
    verifyNever(() => manager.updateUser({'canTranslate': true}));
    expect(repository.session.status, AuthSessionStatus.signedOut);
  });

  test('verification does not hydrate after account changes during update',
      () async {
    final update = Completer<void>();
    when(() => user.emailVerified).thenReturn(false);
    when(() => manager.isEmailVerified()).thenAnswer((_) async => true);
    when(() => manager.updateUser({'canTranslate': true}))
        .thenAnswer((_) => update.future);
    changes.add(user);
    final pending = repository.checkVerification();
    await Future<void>.delayed(Duration.zero);
    when(() => auth.currentUser).thenReturn(null);
    changes.add(null);
    update.complete();
    expect(await pending, isFalse);
    verifyNever(() => manager.initRevenueCat());
    expect(repository.session.status, AuthSessionStatus.signedOut);
  });
}
