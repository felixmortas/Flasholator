import 'package:flasholator/core/providers/ad_provider.dart';
import 'package:flasholator/core/providers/user_data_provider.dart';
import 'package:flasholator/core/services/ad_authorization.dart';
import 'package:flasholator/core/services/ad_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class _Authorization implements AdAuthorization {
  bool allowed = false;
  bool unavailable = false;

  @override
  Future<bool> canShowAds() async {
    if (unavailable) throw StateError('consentement indisponible');
    return allowed;
  }
}

class _RecordingAdService extends AdService {
  int bannerLoads = 0;

  @override
  Future<BannerAd?> loadBanner(double width) async {
    bannerLoads++;
    return null;
  }
}

void main() {
  test('refus, retrait et premium ferment l’accès publicitaire', () async {
    final authorization = _Authorization();
    final container = ProviderContainer(overrides: [
      adAuthorizationProvider.overrideWithValue(authorization),
    ]);
    addTearDown(container.dispose);
    container.read(userDataProvider.notifier).update({'isSubscribed': false});

    expect(await container.read(adEligibilityProvider.future), isFalse);
    authorization.allowed = true;
    container.invalidate(adEligibilityProvider);
    expect(await container.read(adEligibilityProvider.future), isTrue);

    container.read(userDataProvider.notifier).update({'isSubscribed': true});
    expect(await container.read(adEligibilityProvider.future), isFalse);

    container.read(userDataProvider.notifier).update({'isSubscribed': false});
    authorization.allowed = false;
    container.invalidate(adEligibilityProvider);
    expect(await container.read(adEligibilityProvider.future), isFalse);
  });

  test('autorisation indisponible ferme l’accès publicitaire', () async {
    final authorization = _Authorization()..unavailable = true;
    final container = ProviderContainer(overrides: [
      adAuthorizationProvider.overrideWithValue(authorization),
    ]);
    addTearDown(container.dispose);
    expect(await container.read(adEligibilityProvider.future), isFalse);
  });

  test('une bannière refusée ou premium n’est jamais chargée', () async {
    final authorization = _Authorization();
    final ads = _RecordingAdService();
    final container = ProviderContainer(overrides: [
      adAuthorizationProvider.overrideWithValue(authorization),
      adServiceProvider.overrideWithValue(ads),
    ]);
    addTearDown(container.dispose);
    expect(await container.read(bannerAdProvider(320).future), isNull);
    expect(ads.bannerLoads, 0);

    authorization.allowed = true;
    container.read(userDataProvider.notifier).update({'isSubscribed': true});
    container.invalidate(adEligibilityProvider);
    expect(await container.read(bannerAdProvider(321).future), isNull);
    expect(ads.bannerLoads, 0);

    container.read(userDataProvider.notifier).update({'isSubscribed': false});
    container.invalidate(adEligibilityProvider);
    expect(await container.read(bannerAdProvider(322).future), isNull);
    expect(ads.bannerLoads, 1);
  });
}
