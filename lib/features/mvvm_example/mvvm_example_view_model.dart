import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flasholator/core/presentation/application_error.dart';
import 'package:flasholator/features/mvvm_example/mvvm_example_repository.dart';
import 'package:flasholator/features/mvvm_example/mvvm_example_ui_state.dart';

/// Orchestre l'intention de la vue et publie uniquement des états UI immuables.
final class MvvmExampleViewModel extends StateNotifier<MvvmExampleUiState> {
  MvvmExampleViewModel(this._repository)
      : super(const MvvmExampleUiState.initial());

  final MvvmExampleRepository _repository;

  int _commandToken = 0;

  Future<void> load() async {
    final commandToken = ++_commandToken;
    if (!mounted) {
      return;
    }

    state = const MvvmExampleUiState.loading();

    try {
      final message = await _repository.loadMessage();
      if (!mounted || commandToken != _commandToken) {
        return;
      }
      state = MvvmExampleUiState.data(message);
    } on ApplicationError catch (error) {
      if (!mounted || commandToken != _commandToken) {
        return;
      }
      state = MvvmExampleUiState.error(error);
    } catch (error) {
      if (!mounted || commandToken != _commandToken) {
        return;
      }
      state = MvvmExampleUiState.error(UnexpectedApplicationError(error));
    }
  }
}
