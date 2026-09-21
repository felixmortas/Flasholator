import 'package:flasholator/features/translation/translation_request_guard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a late translation is invalidated by a newer request', () {
    final guard = TranslationRequestGuard();
    final first = guard.begin();
    final second = guard.begin();
    expect(guard.isCurrent(first), isFalse);
    expect(guard.isCurrent(second), isTrue);
  });

  test('input or language changes invalidate a pending translation', () {
    final guard = TranslationRequestGuard();
    final pending = guard.begin();
    guard.invalidate();
    expect(guard.isCurrent(pending), isFalse);
  });

  test('only a current response can publish a result and consume quota',
      () async {
    final guard = TranslationRequestGuard();
    String? displayedResult;
    var quotaConsumed = 0;

    Future<void> resolve(String result) async {
      displayedResult = result;
      quotaConsumed++;
    }

    final stale = guard.begin();
    final current = guard.begin();
    await guard.publishIfCurrent(stale, () => resolve('obsolete'));
    expect(displayedResult, isNull);
    expect(quotaConsumed, 0);

    await guard.publishIfCurrent(current, () => resolve('current'));
    expect(displayedResult, 'current');
    expect(quotaConsumed, 1);
  });
}
