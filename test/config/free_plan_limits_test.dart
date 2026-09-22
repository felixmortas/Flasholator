import 'package:flasholator/config/free_plan_limits.dart';
import 'package:flasholator/core/providers/free_plan_limits_provider.dart';
import 'package:flasholator/core/providers/user_data_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('plafonds gratuits par défaut : 1 couple, 200 traductions, 20 paires', () {
    const limits = FreePlanLimits();
    expect(limits.languagePairs, 1);
    expect(limits.translations, 200);
    expect(limits.cardPairs, 20);
    expect(limits.canTranslate(count: 199, isPremium: false), isTrue);
    expect(limits.canTranslate(count: 200, isPremium: false), isFalse);
    expect(limits.canAddCardPair(cardCount: 38, isPremium: false), isTrue);
    expect(limits.canAddCardPair(cardCount: 39, isPremium: false), isFalse);
    expect(limits.canAddCardPair(cardCount: 40, isPremium: false), isFalse);
    expect(limits.canUseLanguagePair(
      usedPairCount: 1, alreadyUsed: false, isPremium: false), isFalse);
  });

  test('premium et plafonds désactivés donnent un accès illimité', () {
    const defaults = FreePlanLimits();
    const disabled = FreePlanLimits(
      languagePairs: null, translations: null, cardPairs: null);
    expect(defaults.canTranslate(count: 10000, isPremium: true), isTrue);
    expect(defaults.canAddCardPair(cardCount: 10000, isPremium: true), isTrue);
    expect(defaults.canUseLanguagePair(
      usedPairCount: 20, alreadyUsed: false, isPremium: true), isTrue);
    expect(disabled.canTranslate(count: 10000, isPremium: false), isTrue);
    expect(disabled.canAddCardPair(cardCount: 10000, isPremium: false), isTrue);
    expect(disabled.canUseLanguagePair(
      usedPairCount: 20, alreadyUsed: false, isPremium: false), isTrue);
  });

  test('une limite de deux couples autorise le second et un couple connu', () {
    const limits = FreePlanLimits(languagePairs: 2);
    expect(limits.canUseLanguagePair(
      usedPairCount: 1, alreadyUsed: false, isPremium: false), isTrue);
    expect(limits.canUseLanguagePair(
      usedPairCount: 2, alreadyUsed: false, isPremium: false), isFalse);
    expect(limits.canUseLanguagePair(
      usedPairCount: 2, alreadyUsed: true, isPremium: false), isTrue);
  });

  test('provider surchargé ignore un ancien drapeau de quota bloqué', () {
    final container = ProviderContainer(overrides: [
      freePlanLimitsProvider.overrideWithValue(
        const FreePlanLimits(translations: 300)),
    ]);
    addTearDown(container.dispose);
    container.read(userDataProvider.notifier).update({
      'counter': 200,
      'canTranslate': false,
      'isSubscribed': false,
    });
    expect(container.read(canTranslateProvider), isTrue);
    container.read(userDataProvider.notifier).update({'counter': 300});
    expect(container.read(canTranslateProvider), isFalse);
    container.read(userDataProvider.notifier).update({'isSubscribed': true});
    expect(container.read(canTranslateProvider), isTrue);
  });

  test('désactiver seulement le quota de traduction laisse les autres actifs', () {
    final container = ProviderContainer(overrides: [
      freePlanLimitsProvider.overrideWithValue(
        const FreePlanLimits(translations: null)),
    ]);
    addTearDown(container.dispose);
    container.read(userDataProvider.notifier).update({
      'counter': 10000,
      'canTranslate': false,
    });
    expect(container.read(canTranslateProvider), isTrue);
    final limits = container.read(freePlanLimitsProvider);
    expect(limits.canAddCardPair(cardCount: 40, isPremium: false), isFalse);
    expect(limits.canUseLanguagePair(
      usedPairCount: 1, alreadyUsed: false, isPremium: false), isFalse);
  });
}
