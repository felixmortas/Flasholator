import 'package:flasholator/core/bootstrap/application_bootstrap.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeStep implements BootstrapStep {
  _FakeStep(this.name, this.calls, {this.error});

  final String name;
  final List<String> calls;
  final Object? error;

  @override
  Future<void> initialize() async {
    calls.add(name);
    if (error != null) throw error!;
  }
}

class _FailOnceStep implements BootstrapStep {
  _FailOnceStep(this.name, this.calls);

  final String name;
  final List<String> calls;
  var _hasFailed = false;

  @override
  Future<void> initialize() async {
    calls.add(name);
    if (!_hasFailed) {
      _hasFailed = true;
      throw StateError(name);
    }
  }
}

void main() {
  test('initialise Flutter, Firebase puis Ads une seule fois', () async {
    final calls = <String>[];
    final bootstrap = ApplicationBootstrap.production(
      flutter: _FakeStep('flutter', calls),
      firebase: _FakeStep('firebase', calls),
      ads: _FakeStep('ads', calls),
      afterAds: [_FakeStep('privacy', calls), _FakeStep('revenuecat', calls)],
    );

    await bootstrap.initialize();
    await bootstrap.initialize();

    expect(calls, ['flutter', 'firebase', 'ads', 'privacy', 'revenuecat']);
  });

  test('arrête la séquence lorsqu’une étape échoue', () async {
    final calls = <String>[];
    final bootstrap = ApplicationBootstrap(
      flutter: _FakeStep('flutter', calls),
      firebase: _FakeStep('firebase', calls, error: StateError('firebase')),
      ads: _FakeStep('ads', calls),
    );

    await expectLater(bootstrap.initialize(), throwsA(isA<StateError>()));
    expect(calls, ['flutter', 'firebase']);
  });

  test('initialise les étapes post-Ads dans leur ordre', () async {
    final calls = <String>[];
    final bootstrap = ApplicationBootstrap(
      flutter: _FakeStep('flutter', calls),
      firebase: _FakeStep('firebase', calls),
      ads: _FakeStep('ads', calls),
      afterAds: [_FakeStep('privacy', calls), _FakeStep('revenuecat', calls)],
    );

    await bootstrap.initialize();

    expect(calls, ['flutter', 'firebase', 'ads', 'privacy', 'revenuecat']);
  });

  test('permet une nouvelle tentative après un échec', () async {
    final calls = <String>[];
    final failingFirebase = _FailOnceStep('firebase', calls);
    final bootstrap = ApplicationBootstrap(
      flutter: _FakeStep('flutter', calls),
      firebase: failingFirebase,
      ads: _FakeStep('ads', calls),
    );

    await expectLater(bootstrap.initialize(), throwsA(isA<StateError>()));
    await bootstrap.initialize();

    expect(calls, ['flutter', 'firebase', 'flutter', 'firebase', 'ads']);
  });
}
