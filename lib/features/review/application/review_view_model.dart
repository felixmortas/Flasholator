import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flasholator/features/flashcards/application/flashcard_collection_projections.dart';
import 'package:flasholator/features/flashcards/data/flashcard_repository.dart';
import 'package:flasholator/features/flashcards/domain/flashcard_collection.dart';
import 'package:flasholator/features/flashcards/domain/flashcard_review_result.dart';
import 'package:flasholator/features/review/application/review_state.dart';

final class ReviewViewModel extends StateNotifier<ReviewState> {
  ReviewViewModel(this._repository, this._clock) : super(const ReviewState()) {
    unawaited(load());
  }

  final FlashcardRepository _repository;
  final DateTime Function() _clock;
  final _effects = StreamController<ReviewEffect>.broadcast();
  int _generation = 0;
  bool _scoreLocked = false;
  bool _disposed = false;
  bool _allLanguages = true;
  String? _sourceLanguage;
  String? _targetLanguage;

  Stream<ReviewEffect> get effects => _effects.stream;

  Future<void> load(
      {bool allLanguages = true,
      String? sourceLanguage,
      String? targetLanguage}) async {
    _allLanguages = allLanguages;
    _sourceLanguage = sourceLanguage;
    _targetLanguage = targetLanguage;
    final generation = ++_generation;
    state = state.copyWith(phase: ReviewPhase.loading, clearError: true);
    try {
      final snapshot = await _repository.loadCollection();
      final due = _dueCards(snapshot);
      if (_disposed || generation != _generation) return;
      state = ReviewState(
          phase: ReviewPhase.data, card: due.isEmpty ? null : due.first);
    } on Object catch (error) {
      if (_disposed || generation != _generation) return;
      state = state.copyWith(
          phase: ReviewPhase.error, error: ReviewLoadError(error));
    }
  }

  void reveal() {
    if (state.phase == ReviewPhase.data &&
        state.card != null &&
        !state.isScoring) {
      state = state.copyWith(isRevealed: true);
    }
  }

  void toggleEditing() {
    if (state.phase != ReviewPhase.data ||
        state.card == null ||
        state.isScoring) {
      return;
    }
    state = state.copyWith(
      isEditing: !state.isEditing,
      clearOverrideQuality: state.isEditing,
    );
  }

  void disablePremiumEditing() {
    if (state.isEditing) {
      state = state.copyWith(isEditing: false, clearOverrideQuality: true);
    }
  }

  void evaluateWrittenAnswer(String answer) {
    final card = state.card;
    if (card == null || !state.isEditing) return;
    state = state.copyWith(
      overrideQuality:
          answer.trim().toLowerCase() == card.back.trim().toLowerCase() ? 4 : 2,
    );
  }

  Future<void> score(int quality) async {
    final card = state.card;
    if (_scoreLocked ||
        card == null ||
        !state.isRevealed ||
        quality < 2 ||
        quality > 5) {
      return;
    }
    _scoreLocked = true;
    ++_generation;
    state = state.copyWith(isScoring: true, clearError: true);
    try {
      final result =
          await _repository.reviewCard(id: card.id, quality: quality);
      if (result != FlashcardReviewResult.applied) {
        throw StateError('La carte à réviser est introuvable.');
      }
      if (_disposed) return;
      // Rafraîchir avec le filtre courant, même après une lecture concurrente.
      final snapshot = await _repository.loadCollection();
      if (_disposed) return;
      final due = _dueCards(snapshot);
      state = ReviewState(
          phase: ReviewPhase.data, card: due.isEmpty ? null : due.first);
      _effects.add(const ReviewScoreAcceptedEffect());
    } on Object catch (error) {
      if (!_disposed) {
        state = state.copyWith(
            isScoring: false,
            phase: ReviewPhase.error,
            error: ReviewScoreError(error));
      }
    } finally {
      _scoreLocked = false;
      if (!_disposed && state.isScoring) {
        state = state.copyWith(isScoring: false);
      }
    }
  }

  List<PersistedFlashcard> _dueCards(FlashcardCollectionSnapshot snapshot) =>
      FlashcardCollectionProjections.review(snapshot, now: _clock())
          .cards
          .where((card) {
        return _allLanguages ||
            (card.sourceLang == _sourceLanguage &&
                card.targetLang == _targetLanguage) ||
            (card.sourceLang == _targetLanguage &&
                card.targetLang == _sourceLanguage);
      }).toList(growable: false);

  @override
  void dispose() {
    _disposed = true;
    unawaited(_effects.close());
    super.dispose();
  }
}
