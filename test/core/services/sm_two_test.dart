import 'package:flasholator/core/services/sm_two.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final date = DateTime.utc(2026, 1, 1);
  test('first review persists the legacy SM-2 vector', () {
    final result = SMTwo.firstReview(4, reviewDate: date);
    expect(result.easiness, 2.5);
    expect(result.interval, 1);
    expect(result.repetitions, 1);
    expect(result.reviewDate, date.add(const Duration(days: 1)));
  });

  test('failed review resets interval and repetitions', () {
    final result = SMTwo(easiness: 2.5, interval: 6, repetitions: 2)
        .review(2, reviewDate: date);
    expect(result.interval, 1);
    expect(result.repetitions, 0);
    expect(result.easiness, closeTo(2.18, 1e-12));
    expect(result.reviewDate, date.add(const Duration(days: 1)));
  });
}
