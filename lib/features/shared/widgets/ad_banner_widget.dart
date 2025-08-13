// lib/widgets/ad_banner_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// Importez vos providers ici
import 'package:flasholator/core/providers/ad_provider.dart';

class AdBannerWidget extends ConsumerWidget {
  const AdBannerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // On peut obtenir la largeur ici, directement dans le contexte du widget
    final screenWidth = MediaQuery.of(context).size.width;

    // On consomme le provider exactement comme avant
    final bannerAdAsyncValue = ref.watch(bannerAdProvider(screenWidth));

    // Ici on place TOUTE la logique d'affichage qui était dans HomePage
    return bannerAdAsyncValue.when(
      // Chargement en cours
      loading: () => Container(
        height: 50.0, // Hauteur typique d'une bannière pour éviter les sauts de layout
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      ),
      
      // Erreur
      error: (err, stack) {
        // En production, il est souvent préférable de ne rien afficher
        debugPrint('Failed to load banner: $err');
        return const SizedBox.shrink();
      },

      // Succès
      data: (bannerAd) {
        if (bannerAd == null) {
          // Cas où l'utilisateur est abonné, que la pub n'a pas chargé, ou non supporté
          return const SizedBox.shrink();
        }

        // On retourne le widget de la bannière prêt à l'emploi
        return SafeArea(
          bottom: false, // Souvent on ne veut pas de SafeArea en bas pour une bannière
          child: SizedBox(
            width: bannerAd.size.width.toDouble(),
            height: bannerAd.size.height.toDouble(),
            child: AdWidget(ad: bannerAd),
          ),
        );
      },
    );
  }
}