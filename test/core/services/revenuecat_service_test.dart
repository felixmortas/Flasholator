import 'package:flasholator/core/services/revenuecat_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(RevenueCatService.resetForTesting);
  tearDown(RevenueCatService.resetForTesting);

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
}
