import 'package:flutter_test/flutter_test.dart';

import 'package:flasholator/core/presentation/application_error.dart';
import 'package:flasholator/core/presentation/ui_phase.dart';
import 'package:flasholator/features/mvvm_example/mvvm_example_ui_state.dart';

final class _ExpectedError implements ApplicationError {
  const _ExpectedError();

  @override
  ApplicationErrorCategory get category => ApplicationErrorCategory.unexpected;

  @override
  String get code => 'expected';
}

void main() {
  test('les états UI ont des phases explicites et restent immuables', () {
    const failure = _ExpectedError();
    const initial = MvvmExampleUiState.initial();
    const loading = MvvmExampleUiState.loading();
    const data = MvvmExampleUiState.data('Chargé');
    const error = MvvmExampleUiState.error(failure);

    expect(initial.phase, UiPhase.initial);
    expect(loading.phase, UiPhase.loading);
    expect(data.phase, UiPhase.data);
    expect(data.message, 'Chargé');
    expect(error.phase, UiPhase.error);
    expect(error.error, same(failure));
    expect(identical(initial, loading), isFalse);
  });

  test('une erreur technique est représentée par une erreur applicative', () {
    const error =
        UnexpectedApplicationError(FormatException('Format invalide'));

    expect(error, isA<ApplicationError>());
    expect(error.category, ApplicationErrorCategory.unexpected);
    expect(error.code, 'unexpected');
  });
}
