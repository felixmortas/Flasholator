import 'package:flasholator/core/providers/user_data_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flasholator/core/services/ad_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

final adServiceProvider = Provider<AdService>((ref) {
  return AdService();
});

final bannerAdProvider = FutureProvider.family<BannerAd?, double>((ref, width) async {
  // Récupère l'état d'abonnement pour décider si on charge la pub
  final isSubscribed = ref.watch(isSubscribedProvider); 
  if (isSubscribed) {
    return null; // Ne pas charger la pub si l'utilisateur est abonné
  }

  // On utilise le service pour encapsuler la logique de configuration
  final adService = ref.watch(adServiceProvider);
  return await adService.loadBanner(width);
});
