import 'package:flasholator/core/providers/user_data_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flasholator/core/services/ad_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flasholator/core/services/ad_authorization.dart';

final adAuthorizationProvider = Provider<AdAuthorization>(
  (ref) => const DeviceAdAuthorization(),
);

final adEligibilityProvider = FutureProvider<bool>((ref) async {
  if (ref.watch(isSubscribedProvider)) return false;
  try {
    return await ref.watch(adAuthorizationProvider).canShowAds();
  } on Object {
    return false;
  }
});

final adServiceProvider = Provider<AdService>((ref) {
  return AdService.shared;
});

final bannerAdProvider =
    FutureProvider.family<BannerAd?, double>((ref, width) async {
  BannerAd? banner;
  var disposed = false;
  ref.onDispose(() {
    disposed = true;
    banner?.dispose();
  });
  // Récupère l'état d'abonnement pour décider si on charge la pub
  final eligible = await ref.watch(adEligibilityProvider.future);
  if (!eligible || ref.read(isSubscribedProvider)) return null;

  // On utilise le service pour encapsuler la logique de configuration
  final adService = ref.watch(adServiceProvider);
  banner = await adService.loadBanner(width);
  if (disposed) {
    banner?.dispose();
    return null;
  }
  bool authorized;
  try {
    authorized = await ref.read(adAuthorizationProvider).canShowAds();
  } on Object {
    authorized = false;
  }
  if (disposed || ref.read(isSubscribedProvider) || !authorized) {
    banner?.dispose();
    banner = null;
    return null;
  }
  return banner;
});
