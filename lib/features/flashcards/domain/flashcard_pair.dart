/// Une face orientée d'une paire de flashcards.
final class FlashcardPairFace {
  final String front;
  final String back;
  final String sourceLang;
  final String targetLang;

  FlashcardPairFace({
    required this.front,
    required this.back,
    required this.sourceLang,
    required this.targetLang,
  }) {
    if (front.trim().isEmpty ||
        back.trim().isEmpty ||
        sourceLang.trim().isEmpty ||
        targetLang.trim().isEmpty) {
      throw ArgumentError('Une face de flashcard doit être entièrement renseignée.');
    }
  }

  FlashcardPairFace get reversed => FlashcardPairFace(
        front: back,
        back: front,
        sourceLang: targetLang,
        targetLang: sourceLang,
      );

  @override
  bool operator ==(Object other) =>
      other is FlashcardPairFace &&
      front == other.front &&
      back == other.back &&
      sourceLang == other.sourceLang &&
      targetLang == other.targetLang;

  @override
  int get hashCode => Object.hash(front, back, sourceLang, targetLang);
}

/// Clé stable qui identifie la paire indépendamment de l'orientation demandée.
final class FlashcardPairKey {
  final String _first;
  final String _second;

  FlashcardPairKey._(this._first, this._second);

  factory FlashcardPairKey.fromFace(FlashcardPairFace face) {
    return FlashcardPairKey.fromValues(
      front: face.front,
      back: face.back,
      sourceLang: face.sourceLang,
      targetLang: face.targetLang,
    );
  }

  /// Construit la clé depuis une ligne persistée, y compris si ses champs ne
  /// satisfont plus la validation du domaine. Le repository peut alors
  /// signaler un conflit au lieu de laisser remonter une erreur de validation.
  factory FlashcardPairKey.fromValues({
    required String front,
    required String back,
    required String sourceLang,
    required String targetLang,
  }) {
    final descriptors = [
      _descriptor(front, back, sourceLang, targetLang),
      _descriptor(back, front, targetLang, sourceLang),
    ]..sort();
    return FlashcardPairKey._(descriptors.first, descriptors.last);
  }

  static String _descriptor(
    String front,
    String back,
    String sourceLang,
    String targetLang,
  ) =>
      [
        front,
        back,
        sourceLang,
        targetLang,
      ].map((value) => '${value.length}:$value').join('|');

  @override
  bool operator ==(Object other) =>
      other is FlashcardPairKey && _first == other._first && _second == other._second;

  @override
  int get hashCode => Object.hash(_first, _second);

}

/// La donnée métier minimale nécessaire pour créer, chercher ou modifier une paire.
final class FlashcardPair {
  final FlashcardPairFace face;

  FlashcardPair({
    required String front,
    required String back,
    required String sourceLang,
    required String targetLang,
  }) : face = FlashcardPairFace(
          front: front,
          back: back,
          sourceLang: sourceLang,
          targetLang: targetLang,
        );

  FlashcardPairFace get reversedFace => face.reversed;
  FlashcardPairKey get key => FlashcardPairKey.fromFace(face);

  @override
  bool operator ==(Object other) => other is FlashcardPair && face == other.face;

  @override
  int get hashCode => face.hashCode;
}
