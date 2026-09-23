import 'dart:async';

import 'package:flasholator/core/services/revenuecat_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

void main() {
  setUp(RevenueCatService.resetForTesting);
  tearDown(RevenueCatService.resetForTesting);

  test('le paywall expose achat, restauration, annulation et attente', () async {
    for (final outcome in PaywallResult.values) {
      final service = RevenueCatService(showPaywall: () async => outcome);
      expect(await service.presentPaywall('A'), outcome);
    }
  });

  test('seul le droit pro confirmé est exposé après restauration', () async {
    final active = RevenueCatService(
      readEntitlement: () async => true,
      restoreEntitlement: () async => true,
    );
    final inactive = RevenueCatService(
      readEntitlement: () async => false,
      restoreEntitlement: () async => false,
    );
    expect(await active.isSubscribed(), isTrue);
    expect(await active.restorePurchases(), isTrue);
    expect(await inactive.isSubscribed(), isFalse);
    expect(await inactive.restorePurchases(), isFalse);
  });

  test('le paywall web signale un lancement refusé et attend le retour',
      () async {
    final rejected = RevenueCatService(
      web: true,
      canOpenPaywall: (_) async => true,
      openPaywall: (_) async => false,
    );
    await expectLater(rejected.presentPaywall('A'), throwsA(isA<StateError>()));
    Uri? opened;
    final launched = RevenueCatService(
      web: true,
      canOpenPaywall: (_) async => true,
      openPaywall: (url) async {
        opened = url;
        return true;
      },
    );
    expect(await launched.presentPaywall('A'), PaywallResult.notPresented);
    expect(opened?.pathSegments.last, 'A');
  });

  test('unverified Firebase account can sign out before configuration', () async {
    var logouts = 0;
    final service = RevenueCatService(logOut: () async { logouts++; });
    await service.logOut();
    expect(logouts, 0);
  });

  test('configuration is unique and identity follows the current uid', () async {
    final configured = <String>[];
    final identified = <String>[];
    var logouts = 0;
    RevenueCatService makeService() => RevenueCatService(
          configure: (uid) async => configured.add(uid),
          logIn: (uid) async => identified.add(uid),
          logOut: () async { logouts++; },
        );
    final first = makeService();
    final second = makeService();
    await first.initRevenueCat('u1');
    await second.initRevenueCat('u1');
    await second.initRevenueCat('u2');
    expect(configured, ['u1']);
    expect(identified, ['u2']);
    await first.logOut();
    expect(logouts, 1);
    await second.initRevenueCat('u2');
    expect(configured, ['u1']);
    expect(identified, ['u2', 'u2']);
  });

  test('login A, logout et login B concurrents restent ordonnés', () async {
    final configureA = Completer<void>();
    final logout = Completer<void>();
    final events = <String>[];
    final service = RevenueCatService(
      configure: (uid) async {
        events.add('configure $uid');
        await configureA.future;
      },
      logOut: () async {
        events.add('logout');
        await logout.future;
      },
      logIn: (uid) async => events.add('login $uid'),
    );

    final a = service.initRevenueCat('A');
    final signOut = service.logOut();
    final b = service.initRevenueCat('B');
    await Future<void>.delayed(Duration.zero);
    expect(events, ['configure A']);
    configureA.complete();
    await a;
    await Future<void>.delayed(Duration.zero);
    expect(events, ['configure A', 'logout']);
    logout.complete();
    await Future.wait([signOut, b]);
    expect(events, ['configure A', 'logout', 'login B']);
    await service.initRevenueCat('B');
    expect(events, ['configure A', 'logout', 'login B']);
  });
}
