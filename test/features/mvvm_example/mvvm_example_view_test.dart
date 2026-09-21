import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flasholator/core/presentation/application_error.dart';
import 'package:flasholator/features/mvvm_example/mvvm_example_providers.dart';
import 'package:flasholator/features/mvvm_example/mvvm_example_repository.dart';
import 'package:flasholator/features/mvvm_example/mvvm_example_view.dart';

final class _FakeRepository implements MvvmExampleRepository {
  _FakeRepository(this._loadMessage);

  final Future<String> Function() _loadMessage;

  @override
  Future<String> loadMessage() => _loadMessage();
}

final class _ExpectedError implements ApplicationError {
  const _ExpectedError();

  @override
  ApplicationErrorCategory get category => ApplicationErrorCategory.unexpected;

  @override
  String get code => 'expected';
}

const _labels = MvvmExampleViewLabels(
  initial: 'État initial',
  loadAction: 'Charger',
  errorMessage: _errorMessage,
);

String _errorMessage(ApplicationError error) {
  return switch (error.code) {
    'expected' => 'Erreur attendue',
    _ => 'Erreur inattendue',
  };
}

void main() {
  testWidgets('rend l’état et délègue l’intention de chargement au ViewModel',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mvvmExampleRepositoryProvider.overrideWithValue(
            _FakeRepository(() async => 'Rendu par le fake'),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: MvvmExampleView(labels: _labels)),
        ),
      ),
    );

    expect(find.text('État initial'), findsOneWidget);
    await tester.tap(find.text('Charger'));
    await tester.pumpAndSettle();

    expect(find.text('Rendu par le fake'), findsOneWidget);
  });

  testWidgets('rend loading et désactive l’intention pendant la commande',
      (tester) async {
    final completion = Completer<String>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mvvmExampleRepositoryProvider.overrideWithValue(
            _FakeRepository(() => completion.future),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: MvvmExampleView(labels: _labels)),
        ),
      ),
    );

    await tester.tap(find.text('Charger'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNull);

    completion.complete('Terminé');
    await tester.pumpAndSettle();
  });

  testWidgets('rend le message localisé de l’erreur applicative',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mvvmExampleRepositoryProvider.overrideWithValue(
            _FakeRepository(() async => throw const _ExpectedError()),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: MvvmExampleView(labels: _labels)),
        ),
      ),
    );

    await tester.tap(find.text('Charger'));
    await tester.pumpAndSettle();

    expect(find.text('Erreur attendue'), findsOneWidget);
  });
}
