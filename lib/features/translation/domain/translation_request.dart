/// Commande de traduction validée, indépendante de tout transport.
final class TranslationRequest {
  const TranslationRequest({
    required this.text,
    required this.sourceLanguage,
    required this.targetLanguage,
  });

  final String text;
  final String sourceLanguage;
  final String targetLanguage;

  bool get isValid =>
      text.trim().isNotEmpty &&
      sourceLanguage.trim().isNotEmpty &&
      targetLanguage.trim().isNotEmpty &&
      sourceLanguage != targetLanguage;
}
