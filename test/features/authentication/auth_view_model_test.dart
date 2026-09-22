import 'dart:async';

import 'package:flasholator/features/authentication/auth_session_repository.dart';
import 'package:flasholator/features/authentication/auth_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _Session extends Mock implements AuthSessionRepository {}

void main() {
  late _Session session;
  late AuthViewModel model;

  setUp(() {
    session = _Session();
    model = AuthViewModel(session);
    addTearDown(model.dispose);
  });

  test('registration exposes completion and ends loading', () async {
    when(() => session.register('a@example.com', 'password', 'Alice'))
        .thenAnswer((_) async {});
    await model.register('a@example.com', 'password', 'Alice');
    expect(model.action.completed, isTrue);
    expect(model.action.loading, isFalse);
  });

  test('registration failure exposes error and ends loading', () async {
    when(() => session.register('a@example.com', 'password', 'Alice'))
        .thenAnswer((_) async => throw StateError('create failed'));
    await model.register('a@example.com', 'password', 'Alice');
    expect(model.action.error, isA<StateError>());
    expect(model.action.loading, isFalse);
  });

  test('verification remains retryable after an error', () async {
    when(() => session.checkVerification())
        .thenAnswer((_) async => throw StateError('network'));
    await model.checkVerification();
    expect(model.action.error, isA<StateError>());
    when(() => session.checkVerification()).thenAnswer((_) async => false);
    await model.checkVerification();
    expect(model.action.verified, isFalse);
    expect(model.action.error, isNull);
  });

  test('an older command cannot overwrite the latest result', () async {
    final first = Completer<void>();
    when(() => session.resetPassword('first@example.com'))
        .thenAnswer((_) => first.future);
    when(() => session.resetPassword('second@example.com'))
        .thenAnswer((_) async => throw StateError('latest'));
    final oldRequest = model.resetPassword('first@example.com');
    await model.resetPassword('second@example.com');
    expect(model.action.error, isA<StateError>());
    first.complete();
    await oldRequest;
    expect(model.action.error, isA<StateError>());
    expect(model.action.completed, isFalse);
  });
}
