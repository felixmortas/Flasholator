import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:flasholator/core/services/ad_service.dart';
import 'package:flasholator/core/services/consent_manager.dart';
import 'package:flasholator/core/services/revenuecat_service.dart';
import 'package:flasholator/firebase_options.dart';

/// Petite frontière injectable autour des SDK exécutés avant [ProviderScope].
abstract interface class BootstrapStep {
  Future<void> initialize();
}

class ApplicationBootstrap {
  ApplicationBootstrap({
    required this.flutter,
    required this.firebase,
    required this.ads,
    this.afterAds = const [],
  });

  final BootstrapStep flutter;
  final BootstrapStep firebase;
  final BootstrapStep ads;
  final List<BootstrapStep> afterAds;

  Future<void>? _initialization;

  /// Exécute chaque étape au plus une fois dans ce cycle de processus.
  Future<void> initialize() =>
      _initialization ??= _initialize().onError((error, stackTrace) {
        _initialization = null;
        Error.throwWithStackTrace(
          error ?? StateError('Échec du bootstrap'),
          stackTrace,
        );
      });

  Future<void> _initialize() async {
    await flutter.initialize();
    await firebase.initialize();
    await ads.initialize();
    for (final step in afterAds) {
      await step.initialize();
    }
  }

  static final ApplicationBootstrap _production = ApplicationBootstrap(
    flutter: const FlutterBindingBootstrapStep(),
    firebase: const FirebaseBootstrapStep(),
    ads: const AdsBootstrapStep(),
    afterAds: const [
      PrivacyAndAdsBootstrapStep(),
    ],
  );

  factory ApplicationBootstrap.production({
    BootstrapStep? flutter,
    BootstrapStep? firebase,
    BootstrapStep? ads,
    List<BootstrapStep>? afterAds,
  }) {
    if (flutter != null ||
        firebase != null ||
        ads != null ||
        afterAds != null) {
      return ApplicationBootstrap(
        flutter: flutter ?? const FlutterBindingBootstrapStep(),
        firebase: firebase ?? const FirebaseBootstrapStep(),
        ads: ads ?? const AdsBootstrapStep(),
        afterAds: afterAds ??
            const [
              PrivacyAndAdsBootstrapStep(),
            ],
      );
    }
    return _production;
  }
}

class FlutterBindingBootstrapStep implements BootstrapStep {
  const FlutterBindingBootstrapStep();

  @override
  Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
  }
}

class FirebaseBootstrapStep implements BootstrapStep {
  const FirebaseBootstrapStep();

  @override
  Future<void> initialize() => Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
}

class AdsBootstrapStep implements BootstrapStep {
  const AdsBootstrapStep();

  @override
  Future<void> initialize() => AdService.initialize();
}

/// Conserve le flux UMP/ATT et le préchargement sans le laisser à une vue.
class PrivacyAndAdsBootstrapStep implements BootstrapStep {
  const PrivacyAndAdsBootstrapStep();

  @override
  Future<void> initialize() async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;

    try {
      await ConsentManager.initialize();
    } on Object {
      // Une indisponibilité UMP ferme l'accès aux annonces, sans bloquer l'app.
    }
    if (Platform.isIOS) {
      try {
        if (await AppTrackingTransparency.trackingAuthorizationStatus ==
            TrackingStatus.notDetermined) {
          await Future<void>.delayed(const Duration(seconds: 1));
          await AppTrackingTransparency.requestTrackingAuthorization();
        }
      } on Object {
        // Une autorisation ATT inconnue ou indisponible bloque les annonces.
      }
    }
  }
}

/// Restaure la session RevenueCat existante une fois Firebase disponible.
class RevenueCatSessionBootstrapStep implements BootstrapStep {
  const RevenueCatSessionBootstrapStep();

  @override
  Future<void> initialize() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await RevenueCatService().initRevenueCat(user.uid);
    }
  }
}
