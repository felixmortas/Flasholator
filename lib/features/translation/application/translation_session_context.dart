/// Identité immutable de la session qui possède une intention de traduction.
final class TranslationSessionContext {
  const TranslationSessionContext({
    required this.sessionId,
    required this.generation,
  });

  final String sessionId;
  final int generation;

  @override
  bool operator ==(Object other) =>
      other is TranslationSessionContext &&
      other.sessionId == sessionId &&
      other.generation == generation;

  @override
  int get hashCode => Object.hash(sessionId, generation);
}
