import 'package:flasholator/core/presentation/ui_phase.dart';
import 'package:flasholator/features/translation/domain/translation_error.dart';
import 'package:flasholator/features/translation/domain/translation_result.dart';

/// Etat UI immutable de la demande de traduction courante.
final class TranslationUiState {
  const TranslationUiState._({
    required this.phase,
    this.result,
    this.error,
  });

  const TranslationUiState.initial() : this._(phase: UiPhase.initial);
  const TranslationUiState.loading() : this._(phase: UiPhase.loading);
  const TranslationUiState.data(TranslationResult result)
      : this._(phase: UiPhase.data, result: result);
  const TranslationUiState.error(TranslationError error)
      : this._(phase: UiPhase.error, error: error);

  final UiPhase phase;
  final TranslationResult? result;
  final TranslationError? error;
}
