import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flasholator/features/flashcards/flashcard_providers.dart';
import 'package:flasholator/features/review/application/review_state.dart';
import 'package:flasholator/features/review/application/review_view_model.dart';

final reviewViewModelProvider =
    StateNotifierProvider<ReviewViewModel, ReviewState>((ref) {
  return ReviewViewModel(
    ref.watch(flashcardRepositoryProvider),
    ref.watch(flashcardClockProvider),
  );
});
