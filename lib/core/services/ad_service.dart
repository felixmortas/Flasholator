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

  // ---------- IDs de test ----------
  final String interstitialAdUnitId = 'ca-app-pub-9706580094748746/2652484340'; // Test ID : ca-app-pub-3940256099942544/1033173712
  final String bannerAdUnitId = 'ca-app-pub-9706580094748746/7892523530'; // Test ID : ca-app-pub-3940256099942544/9214589741

  // ---------- INITIALISATION ----------
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
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
  Future<void> loadBanner(BuildContext context) async {
    if (_isBannerLoadedOnce) return;
    _isBannerLoadedOnce = true;

    if (!_shouldShowBanner()) return;

    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      MediaQuery.of(context).size.width.truncate(),
    );

    if (size == null) {
      debugPrint('Unable to get banner ad size.');
      return;
    }

    final ad = BannerAd(
      adUnitId: bannerAdUnitId,
      request: const AdRequest(),
      size: size,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint("Banner loaded.");
          _bannerAd = ad as BannerAd;
          _isBannerLoaded = true;
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint("Banner failed to load: $error");
          ad.dispose();
        },
      ),
    );

    ad.load();
  }

  bool _shouldShowBanner() {
    return !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  }

  Widget? getBannerWidget() {
    if (_isBannerLoaded && _bannerAd != null && _shouldShowBanner()) {
      return SafeArea(
        child: SizedBox(
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        ),
      );
    }
    return null;
  }

  // ---------- DISPOSE ----------
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
  }
}
