import 'package:flasholator/features/translation/domain/translation_error.dart';
import 'package:flasholator/features/translation/domain/translation_request.dart';
import 'package:flasholator/features/translation/domain/translation_repository.dart';
import 'package:flasholator/features/translation/domain/translation_result.dart';

abstract interface class DeeplTranslationClient {
  Future<String> translate({
    required String text,
    required String targetLanguage,
    required String sourceLanguage,
  });
}

/// Adaptateur de compatibilité pour le client DeepL historique.
final class DeeplTranslationRepository implements TranslationRepository {
  DeeplTranslationRepository(this._client);

  final DeeplTranslationClient _client;

  @override
  Future<TranslationResult> translate(TranslationRequest request) async {
    try {
      final text = await _client.translate(
        text: request.text,
        targetLanguage: request.targetLanguage,
        sourceLanguage: request.sourceLanguage,
      );
      if (text.trim().isEmpty) {
        throw const TranslationError(TranslationErrorKind.deepl);
      }
      return TranslationResult(
        sourceText: request.text,
        text: text,
        sourceLanguage: request.sourceLanguage,
        targetLanguage: request.targetLanguage,
      );
    } on TranslationError {
      rethrow;
    } catch (error) {
      throw TranslationError(TranslationErrorKind.deepl, error);
    }
  }
}
