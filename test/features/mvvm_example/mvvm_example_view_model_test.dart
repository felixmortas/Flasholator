import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flasholator/core/presentation/application_error.dart';
import 'package:flasholator/core/presentation/ui_phase.dart';
import 'package:flasholator/features/mvvm_example/mvvm_example_providers.dart';
import 'package:flasholator/features/mvvm_example/mvvm_example_repository.dart';
import 'package:flasholator/features/mvvm_example/mvvm_example_ui_state.dart';

final class _FakeRepository implements MvvmExampleRepository {
  _FakeRepository(this._loadMessage);

  final Future<String> Function() _loadMessage;
  var calls = 0;

  @override
  Future<String> loadMessage() {
    calls++;
    return _loadMessage();
  }
}

final class _ExpectedError implements ApplicationError {
  const _ExpectedError();

  @override
  ApplicationErrorCategory get category => ApplicationErrorCategory.unexpected;

  @override
  String get code => 'expected';
}

void main() {
  test('publie initial, loading puis data avec une nouvelle instance immuable', () async {
    final completion = Completer<String>();
    final fake = _FakeRepository(() => completion.future);
    final container = ProviderContainer(
      overrides: [mvvmExampleRepositoryProvider.overrideWithValue(fake)],
    );
    addTearDown(container.dispose);

    final states = <MvvmExampleUiState>[];
    container.listen(mvvmExampleViewModelProvider, (_, next) {
      states.add(next);
    }, fireImmediately: true);

    final command = container.read(mvvmExampleViewModelProvider.notifier).load();
    expect(container.read(mvvmExampleViewModelProvider).phase, UiPhase.loading);

    completion.complete('Depuis le fake');
    await command;

    final state = container.read(mvvmExampleViewModelProvider);
    expect(states.map((state) => state.phase), [
      UiPhase.initial,
      UiPhase.loading,
      UiPhase.data,
    ]);
    expect(identical(states[0], states[1]), isFalse);
    expect(identical(states[1], states[2]), isFalse);
    expect(state.message, 'Depuis le fake');
    expect(fake.calls, 1);
  });

  test('publie une erreur applicative typée quand la dépendance échoue', () async {
    const expectedError = _ExpectedError();
    final fake = _FakeRepository(() async => throw expectedError);
    final container = ProviderContainer(
      overrides: [mvvmExampleRepositoryProvider.overrideWithValue(fake)],
    );
    addTearDown(container.dispose);

    await container.read(mvvmExampleViewModelProvider.notifier).load();

    final state = container.read(mvvmExampleViewModelProvider);
    expect(state.phase, UiPhase.error);
    expect(state.error, same(expectedError));
    expect(fake.calls, 1);
  });

  test('ignore l’achèvement hors ordre d’une commande devenue périmée',
      () async {
    final first = Completer<String>();
    final second = Completer<String>();
    var invocation = 0;
    final fake = _FakeRepository(() {
      invocation++;
      return invocation == 1 ? first.future : second.future;
    });
    final container = ProviderContainer(
      overrides: [mvvmExampleRepositoryProvider.overrideWithValue(fake)],
    );
    addTearDown(container.dispose);

    final viewModel = container.read(mvvmExampleViewModelProvider.notifier);
    final firstCommand = viewModel.load();
    final secondCommand = viewModel.load();
    second.complete('Résultat courant');
    await secondCommand;

    first.complete('Résultat périmé');
    await firstCommand;

    final state = container.read(mvvmExampleViewModelProvider);
    expect(state.phase, UiPhase.data);
    expect(state.message, 'Résultat courant');
    expect(fake.calls, 2);
  });

  test('convertit une erreur technique en erreur applicative inattendue',
      () async {
    final technicalError = StateError('Détail technique');
    final fake = _FakeRepository(() async => throw technicalError);
    final container = ProviderContainer(
      overrides: [mvvmExampleRepositoryProvider.overrideWithValue(fake)],
    );
    addTearDown(container.dispose);

    await container.read(mvvmExampleViewModelProvider.notifier).load();

    final state = container.read(mvvmExampleViewModelProvider);
    expect(state.phase, UiPhase.error);
    expect(state.error, isA<UnexpectedApplicationError>());
    expect(state.error!.category, ApplicationErrorCategory.unexpected);
    expect(state.error!.code, 'unexpected');
    expect((state.error! as UnexpectedApplicationError).cause,
        same(technicalError));
  });

  test('ne publie pas après la destruction du ViewModel', () async {
    final completion = Completer<String>();
    final fake = _FakeRepository(() => completion.future);
    final container = ProviderContainer(
      overrides: [mvvmExampleRepositoryProvider.overrideWithValue(fake)],
    );
    final viewModel = container.read(mvvmExampleViewModelProvider.notifier);

    final command = viewModel.load();
    container.dispose();
    completion.complete('Résultat tardif');

    await expectLater(command, completes);
  });
}
