import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService shared = AdService();
  static Future<void>? _sdkInitialization;
  // ---------- Interstitial ----------
  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoaded = false;
  bool _isInterstitialLoading = false;

  // ---------- Banner ----------

  // ---------- IDs ----------
  final String interstitialAdUnitId =
      'ca-app-pub-9706580094748746/2652484340'; // Test ID : ca-app-pub-3940256099942544/1033173712
  final String bannerAdUnitId =
      'ca-app-pub-9706580094748746/7892523530'; // Test ID : ca-app-pub-3940256099942544/9214589741

  // ---------- INITIALISATION ----------
  static Future<void> initialize() =>
      _sdkInitialization ??= _initializeSdk().onError((error, stackTrace) {
        _sdkInitialization = null;
        Error.throwWithStackTrace(
          error ?? StateError('Échec de l’initialisation Ads'),
          stackTrace,
        );
      });

  static Future<void> _initializeSdk() async {
    if (!kIsWeb) {
      await MobileAds.instance.initialize();

      final config = RequestConfiguration(
        testDeviceIds: ['E779AA37025CA3C4EE7B28A571BDA15A'], // Ton ID de test
      );
      await MobileAds.instance.updateRequestConfiguration(config);
    }
  }

  Future<bool> _authorized(Future<bool> Function() eligible) async {
    try {
      return await eligible();
    } on Object {
      return false;
    }
  }

  // ---------- INTERSTITIAL ----------
  Future<void> loadInterstitial(Future<bool> Function() eligible) async {
    if (_isInterstitialLoaded || _isInterstitialLoading) return;
    if (!await _authorized(eligible)) {
      clearInterstitial();
      return;
    }
    _isInterstitialLoading = true;
    try {
      InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) async {
            _isInterstitialLoading = false;
            if (!await _authorized(eligible)) {
              ad.dispose();
              return;
            }
            _interstitialAd = ad;
            _isInterstitialLoaded = true;
            _interstitialAd?.setImmersiveMode(true);
            _interstitialAd?.fullScreenContentCallback =
                FullScreenContentCallback(
              onAdDismissedFullScreenContent: (InterstitialAd ad) {
                ad.dispose();
                _interstitialAd = null;
                _isInterstitialLoaded = false;
              },
              onAdFailedToShowFullScreenContent:
                  (InterstitialAd ad, AdError error) {
                ad.dispose();
                _interstitialAd = null;
                _isInterstitialLoaded = false;
              },
            );
          },
          onAdFailedToLoad: (LoadAdError error) {
            _isInterstitialLoading = false;
            _isInterstitialLoaded = false;
            _interstitialAd = null;
          },
        ),
      );
    } on Object {
      _isInterstitialLoading = false;
      clearInterstitial();
    }
  }

  Future<void> showInterstitial(Future<bool> Function() eligible) async {
    if (!await _authorized(eligible)) {
      clearInterstitial();
      return;
    }
    if (_isInterstitialLoaded && _interstitialAd != null) {
      try {
        _interstitialAd?.show();
        _isInterstitialLoaded = false;
      } on Object {
        clearInterstitial();
      }
    } else {
      await loadInterstitial(eligible);
    }
  }

  void clearInterstitial() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialLoaded = false;
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
      adUnitId:
          bannerAdUnitId, // Assurez-vous que cette variable est accessible
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
    clearInterstitial();
  }
}

void disposeBanner(BannerAd? banner) {
  banner?.dispose();
}
