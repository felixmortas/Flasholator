import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';
import 'package:flasholator/core/services/consent_manager.dart';

/// Autorisation courante, relue avant chaque demande et affichage d'annonce.
abstract interface class AdAuthorization {
  Future<bool> canShowAds();
}

class DeviceAdAuthorization implements AdAuthorization {
  const DeviceAdAuthorization();

  @override
  Future<bool> canShowAds() async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return false;
    try {
      if (!await ConsentManager.canRequestAds()) return false;
      if (Platform.isIOS) {
        return await AppTrackingTransparency.trackingAuthorizationStatus ==
            TrackingStatus.authorized;
      }
      return true;
    } on Object {
      return false;
    }
  }
}
