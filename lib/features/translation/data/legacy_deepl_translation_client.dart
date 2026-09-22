import 'package:flasholator/core/services/deepl_translator.dart';
import 'package:flasholator/features/translation/data/deepl_translation_repository.dart';

/// Frontière de compatibilité du client historique : son littéral d'échec ne
/// quitte jamais l'adaptateur et la vue affiche sa localisation habituelle.
final class LegacyDeeplTranslationClient implements DeeplTranslationClient {
  LegacyDeeplTranslationClient(this._translator);

  final DeeplTranslator _translator;

  @override
  Future<String> translate({
    required String text,
    required String targetLanguage,
    required String sourceLanguage,
  }) async {
    final response = await _translator.translate(text, targetLanguage, sourceLanguage);
    if (response == 'Erreur de connexion') {
      throw const LegacyDeeplConnectionException();
    }
    return response;
  }
}

final class LegacyDeeplConnectionException implements Exception {
  const LegacyDeeplConnectionException();
}
