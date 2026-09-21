import 'package:flasholator/core/models/flashcard.dart';
import 'package:flasholator/core/services/db_wrapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026, 1, 2, 12);
  Flashcard card({DateTime? due}) => Flashcard(
        id: 7, front: 'bonjour', back: 'hello', sourceLang: 'FR', targetLang: 'EN',
        addedDate: now, quality: 4, easiness: 2.36, interval: 6, repetitions: 2,
        timesReviewed: 3, lastReviewDate: now, nextReviewDate: due);

  test('round-trip Drift preserves every flashcard field', () {
    final original = card(due: now.add(const Duration(days: 6)));
    final companion = original.toDriftCompanion();
    final restored = Flashcard.fromDrift(FlashcardData(
      id: companion.id.value, front: companion.front.value, back: companion.back.value,
      sourceLang: companion.sourceLang.value, targetLang: companion.targetLang.value,
      addedDate: companion.addedDate.value, quality: companion.quality.value,
      easiness: companion.easiness.value, interval: companion.interval.value,
      repetitions: companion.repetitions.value, timesReviewed: companion.timesReviewed.value,
      lastReviewDate: companion.lastReviewDate.value, nextReviewDate: companion.nextReviewDate.value,
    ));
    expect(restored.toMap(), original.toMap());
  });

  test('due includes null, past and now but excludes a future date', () {
    expect(card().isDue(now: now), isTrue);
    expect(card(due: now.subtract(const Duration(seconds: 1))).isDue(now: now), isTrue);
    expect(card(due: now).isDue(now: now), isTrue);
    expect(card(due: now.add(const Duration(seconds: 1))).isDue(now: now), isFalse);
  });
}
