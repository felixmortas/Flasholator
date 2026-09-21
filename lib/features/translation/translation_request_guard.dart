import 'dart:async';

/// Monotonic request token used by the legacy translation view.
///
/// Starting a request or changing its input invalidates every older response.
class TranslationRequestGuard {
  int _current = 0;

  int begin() => ++_current;
  void invalidate() => ++_current;
  bool isCurrent(int token) => token == _current;

  /// Publishes a translation result (and its quota side effect) atomically
  /// with respect to the current request token.
  Future<bool> publishIfCurrent(
    int token,
    FutureOr<void> Function() publish,
  ) async {
    if (!isCurrent(token)) return false;
    await publish();
    return true;
  }
}
