import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flasholator/features/translation/application/translation_session_context.dart';
import 'package:flasholator/features/translation/application/translation_ui_state.dart';
import 'package:flasholator/features/translation/domain/translation_error.dart';
import 'package:flasholator/features/translation/domain/translation_repository.dart';
import 'package:flasholator/features/translation/domain/translation_request.dart';
import 'package:flasholator/features/translation/domain/translation_result.dart';

/// Orchestre une intention remplaçable et ignore toute complétion périmée.
final class TranslationViewModel extends StateNotifier<TranslationUiState> {
  TranslationViewModel(this._repository, this._sessionContext)
      : super(const TranslationUiState.initial());

  final TranslationRepository _repository;
  final TranslationSessionContext Function() _sessionContext;
  int _requestToken = 0;

  void invalidate() {
    ++_requestToken;
    if (mounted) state = const TranslationUiState.initial();
  }

  void sessionChanged(TranslationSessionContext _) => invalidate();

  Future<TranslationResult?> translate({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    final request = TranslationRequest(
      text: text.trim(),
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
    );
    final session = _sessionContext();
    final token = ++_requestToken;
    if (!mounted || !request.isValid) {
      if (mounted) state = const TranslationUiState.initial();
      return null;
    }
    state = const TranslationUiState.loading();
    try {
      final result = await _repository.translate(request);
      if (!_isCurrent(token, session)) return null;
      final currentResult = TranslationResult(
        sourceText: request.text,
        text: result.text,
        sourceLanguage: result.sourceLanguage,
        targetLanguage: result.targetLanguage,
      );
      state = TranslationUiState.data(currentResult);
      return currentResult;
    } on TranslationError catch (error) {
      if (!_isCurrent(token, session)) return null;
      state = TranslationUiState.error(error);
    } catch (error) {
      if (!_isCurrent(token, session)) return null;
      state = TranslationUiState.error(
        TranslationError(TranslationErrorKind.unexpected, error),
      );
    }
    return null;
  }

  bool _isCurrent(int token, TranslationSessionContext session) =>
      mounted && token == _requestToken && session == _sessionContext();
}
