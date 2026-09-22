/// Résultat métier d'une traduction DeepL réussie.
final class TranslationResult {
  const TranslationResult({
    required this.sourceText,
    required this.text,
    required this.sourceLanguage,
    required this.targetLanguage,
  });

  final String text;
  final String sourceText;
  final String sourceLanguage;
  final String targetLanguage;
}
