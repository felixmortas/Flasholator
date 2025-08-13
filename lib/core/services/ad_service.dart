import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  // ---------- Interstitial ----------
  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoaded = false;

  // ---------- Banner ----------
  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;
  bool _isBannerLoadedOnce = false;

  // ---------- IDs ----------
  final String interstitialAdUnitId = 'ca-app-pub-9706580094748746/2652484340'; // Test ID : ca-app-pub-3940256099942544/1033173712
  final String bannerAdUnitId = 'ca-app-pub-9706580094748746/7892523530'; // Test ID : ca-app-pub-3940256099942544/9214589741

  // ---------- INITIALISATION ----------
  static Future<void> initialize() async {
    if (!kIsWeb) {
      await MobileAds.instance.initialize();

      final config = RequestConfiguration(
        testDeviceIds: ['E779AA37025CA3C4EE7B28A571BDA15A'], // Ton ID de test
      );
      await MobileAds.instance.updateRequestConfiguration(config);
    }
  }

  // ---------- INTERSTITIAL ----------
  void loadInterstitial() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _isInterstitialLoaded = true;
          _interstitialAd?.setImmersiveMode(true);
          _interstitialAd?.fullScreenContentCallback =
              FullScreenContentCallback(
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              ad.dispose();
              loadInterstitial();
            },
            onAdFailedToShowFullScreenContent:
                (InterstitialAd ad, AdError error) {
              ad.dispose();
              loadInterstitial();
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isInterstitialLoaded = false;
          _interstitialAd = null;
        },
      ),
    );
  }

  void showInterstitial() {
    if (_isInterstitialLoaded && _interstitialAd != null) {
      _interstitialAd?.show();
      _isInterstitialLoaded = false;
    } else {
      loadInterstitial();
    }
  }

  // ---------- BANNER ----------
  Future<BannerAd?> loadBanner(double width) async {
    if (!_shouldShowBanner()) return null;

    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      width.truncate(),
    );

    if (size == null) {
      debugPrint('Unable to get banner ad size.');
      return null;
    }
    
    // On utilise un Completer pour transformer le callback en Future
    final completer = Completer<BannerAd?>();

    final ad = BannerAd(
      adUnitId: bannerAdUnitId, // Assurez-vous que cette variable est accessible
      request: const AdRequest(),
      size: size,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint("Banner loaded successfully.");
          completer.complete(ad as BannerAd);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint("Banner failed to load: $error");
          ad.dispose();
          completer.complete(null); // Complète avec null en cas d'échec
        },
      ),
    );

    ad.load();
    return completer.future;
  }
  
  bool _shouldShowBanner() {
    // Votre logique existante
    return !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  }


  // ---------- DISPOSE ----------
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
  }
}

  void disposeBanner(BannerAd? banner) {
    banner?.dispose();
  }

