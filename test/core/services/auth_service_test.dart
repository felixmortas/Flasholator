import 'package:firebase_auth/firebase_auth.dart';
import 'package:flasholator/core/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

void main() {
  late MockFirebaseAuth auth;
  late AuthService service;
  setUp(() {
    auth = MockFirebaseAuth();
    service = AuthService(firebaseAuth: auth);
  });

  test('absent user keeps the observable empty contracts', () async {
    when(() => auth.currentUser).thenReturn(null);
    expect(service.getUserEmail(), '');
    expect(service.getUserId(), '');
    expect(service.getUserName(), '');
    expect(await service.isEmailVerified(), isFalse);
    await service.sendEmailVerification();
  });

  test('registration, login, reset and sign out keep their Firebase contracts',
      () async {
    when(() => auth.createUserWithEmailAndPassword(
            email: any(named: 'email'), password: any(named: 'password')))
        .thenAnswer((_) async => MockUserCredential());
    when(() => auth.signInWithEmailAndPassword(
            email: any(named: 'email'), password: any(named: 'password')))
        .thenAnswer((_) async => MockUserCredential());
    when(() => auth.sendPasswordResetEmail(email: any(named: 'email')))
        .thenAnswer((_) async {});
    when(() => auth.signOut()).thenAnswer((_) async {});
    await service.registerUser('a@example.com', 'pw');
    await service.login('a@example.com', 'pw');
    await service.sendPasswordResetEmail('a@example.com');
    await service.signOut();
    verify(() => auth.createUserWithEmailAndPassword(
        email: 'a@example.com', password: 'pw')).called(1);
    verify(() => auth.signInWithEmailAndPassword(
        email: 'a@example.com', password: 'pw')).called(1);
    verify(() => auth.sendPasswordResetEmail(email: 'a@example.com')).called(1);
    verify(() => auth.signOut()).called(1);
  });

  test('auth-state stream is forwarded and login errors reach the caller',
      () async {
    when(() => auth.authStateChanges()).thenAnswer((_) => Stream.value(null));
    when(() => auth.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer(
      (_) async => throw FirebaseAuthException(code: 'invalid-credential'),
    );

    await expectLater(
        service.authStateChanges(), emitsInOrder([isNull, emitsDone]));
    await expectLater(service.login('a@example.com', 'wrong'),
        throwsA(isA<FirebaseAuthException>()
            .having((error) => error.code, 'code', 'invalid-credential')));
    verify(() => auth.signInWithEmailAndPassword(
          email: 'a@example.com',
          password: 'wrong',
        )).called(1);
  });
}
