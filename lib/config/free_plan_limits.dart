/// Plafonds de l'offre gratuite. `null` désactive individuellement un plafond.
final class FreePlanLimits {
  const FreePlanLimits({
    this.languagePairs = 1,
    this.translations = 200,
    this.cardPairs = 20,
  })  : assert(languagePairs == null || languagePairs >= 0),
        assert(translations == null || translations >= 0),
        assert(cardPairs == null || cardPairs >= 0);

  final int? languagePairs;
  final int? translations;
  final int? cardPairs;

  bool canTranslate({required int count, required bool isPremium}) =>
      isPremium || translations == null || count < translations!;

  bool canAddCardPair({required int cardCount, required bool isPremium}) =>
      isPremium || cardPairs == null || cardCount + 2 <= cardPairs! * 2;

  bool canUseLanguagePair({
    required int usedPairCount,
    required bool alreadyUsed,
    required bool isPremium,
  }) => isPremium || alreadyUsed || languagePairs == null ||
      usedPairCount < languagePairs!;
}
