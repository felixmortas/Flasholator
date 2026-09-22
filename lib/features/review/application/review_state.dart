import 'package:flasholator/features/flashcards/domain/flashcard_collection.dart';

enum ReviewPhase { initial, loading, data, error }

sealed class ReviewError implements Exception {
  const ReviewError();
}

final class ReviewLoadError extends ReviewError {
  const ReviewLoadError(this.cause);
  final Object cause;
}

final class ReviewScoreError extends ReviewError {
  const ReviewScoreError(this.cause);
  final Object cause;
}

/// Etat immutable, réhydratable : les effets ponctuels n'y figurent pas.
final class ReviewState {
  const ReviewState({
    this.phase = ReviewPhase.initial,
    this.card,
    this.isRevealed = false,
    this.isScoring = false,
    this.isEditing = false,
    this.overrideQuality,
    this.error,
  });

  final ReviewPhase phase;
  final PersistedFlashcard? card;
  final bool isRevealed;
  final bool isScoring;
  final bool isEditing;
  final int? overrideQuality;
  final ReviewError? error;

  ReviewState copyWith({
    ReviewPhase? phase,
    PersistedFlashcard? card,
    bool clearCard = false,
    bool? isRevealed,
    bool? isScoring,
    bool? isEditing,
    int? overrideQuality,
    bool clearOverrideQuality = false,
    ReviewError? error,
    bool clearError = false,
  }) =>
      ReviewState(
        phase: phase ?? this.phase,
        card: clearCard ? null : card ?? this.card,
        isRevealed: isRevealed ?? this.isRevealed,
        isScoring: isScoring ?? this.isScoring,
        isEditing: isEditing ?? this.isEditing,
        overrideQuality: clearOverrideQuality
            ? null
            : overrideQuality ?? this.overrideQuality,
        error: clearError ? null : error ?? this.error,
      );
}

sealed class ReviewEffect {
  const ReviewEffect();
}

final class ReviewScoreAcceptedEffect extends ReviewEffect {
  const ReviewScoreAcceptedEffect();
}
