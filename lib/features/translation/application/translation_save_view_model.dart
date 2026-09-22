import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flasholator/features/flashcards/data/flashcard_repository.dart';
import 'package:flasholator/features/flashcards/domain/flashcard_pair.dart';
import 'package:flasholator/features/flashcards/domain/flashcard_pair_mutation_result.dart';
import 'package:flasholator/features/translation/application/translation_save_state.dart';
import 'package:flasholator/features/translation/application/translation_session_context.dart';
import 'package:flasholator/features/translation/domain/translation_result.dart';

/// Enregistre seulement le résultat de traduction encore courant.
final class TranslationSaveViewModel extends StateNotifier<TranslationSaveState> {
  TranslationSaveViewModel(this._repository, this._sessionContext)
      : super(const TranslationSaveState.initial());

  final FlashcardRepository _repository;
  final TranslationSessionContext Function() _sessionContext;
  int _token = 0;

  void invalidate() => ++_token;

  Future<FlashcardPairMutationResult?> save({
    required TranslationResult result,
    required bool Function() isCurrent,
  }) async {
    final token = ++_token;
    final session = _sessionContext();
    if (!mounted || !isCurrent()) return null;
    state = const TranslationSaveState.saving();
    try {
      if (!_isCurrent(token, session, isCurrent)) return null;
      final mutation = await _repository.addPair(FlashcardPair(
        front: _formatCardText(result.sourceText),
        back: _formatCardText(result.text),
        sourceLang: result.sourceLanguage,
        targetLang: result.targetLanguage,
      ));
      if (!_isCurrent(token, session, isCurrent)) return null;
      state = TranslationSaveState.result(mutation);
      return mutation;
    } catch (error) {
      if (!_isCurrent(token, session, isCurrent)) return null;
      state = TranslationSaveState.error(error);
      return null;
    }
  }

  bool _isCurrent(int token, TranslationSessionContext session, bool Function() current) =>
      mounted && token == _token && session == _sessionContext() && current();

  String _formatCardText(String value) {
    final normalized = value.toLowerCase();
    return normalized.isEmpty
        ? normalized
        : '${normalized[0].toUpperCase()}${normalized.substring(1)}';
  }
}
