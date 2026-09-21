import 'package:flasholator/core/presentation/application_error.dart';
import 'package:flasholator/core/presentation/ui_phase.dart';

/// État immuable rendu par la vue de l'exemple.
final class MvvmExampleUiState {
  const MvvmExampleUiState._({
    required this.phase,
    this.message,
    this.error,
  });

  const MvvmExampleUiState.initial() : this._(phase: UiPhase.initial);

  const MvvmExampleUiState.loading() : this._(phase: UiPhase.loading);

  const MvvmExampleUiState.data(String message)
      : this._(phase: UiPhase.data, message: message);

  const MvvmExampleUiState.error(ApplicationError error)
      : this._(phase: UiPhase.error, error: error);

  final UiPhase phase;
  final String? message;
  final ApplicationError? error;
}
