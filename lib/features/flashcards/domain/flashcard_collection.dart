/// Représentation immuable, indépendante de Drift, d'une ligne persistée.
/// Les treize champs de la table sont conservés à cette frontière.
final class PersistedFlashcard {
  const PersistedFlashcard({
    required this.id,
    required this.front,
    required this.back,
    required this.sourceLang,
    required this.targetLang,
    required this.addedDate,
    required this.quality,
    required this.easiness,
    required this.interval,
    required this.repetitions,
    required this.timesReviewed,
    required this.lastReviewDate,
    required this.nextReviewDate,
  });

  final int id;
  final String front;
  final String back;
  final String sourceLang;
  final String targetLang;
  final DateTime addedDate;
  final int? quality;
  final double easiness;
  final int interval;
  final int repetitions;
  final int timesReviewed;
  final DateTime? lastReviewDate;
  final DateTime? nextReviewDate;
}

/// Version cohérente de la collection locale, sans liste mutable partagée.
final class FlashcardCollectionSnapshot {
  FlashcardCollectionSnapshot(
      {required this.version, required Iterable<PersistedFlashcard> cards})
      : cards = List.unmodifiable(cards);

  final int version;
  final List<PersistedFlashcard> cards;
}
