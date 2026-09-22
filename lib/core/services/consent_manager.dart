import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class ConsentManager {
  static Future<bool> initialize() {
    final completer = Completer<bool>();
    final params = ConsentRequestParameters();

    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () {
        debugPrint("Consent info updated.");
        ConsentForm.loadAndShowConsentFormIfRequired((formError) {
          if (formError != null) {
            debugPrint("Consent form error: ${formError.message}");
            completer.completeError(StateError(formError.message));
          } else {
            debugPrint("Consent form loaded and shown.");
            ConsentInformation.instance
                .canRequestAds()
                .then(completer.complete);
          }
        });
      },
      (FormError error) {
        debugPrint("Consent info update error: ${error.message}");
        completer.completeError(StateError(error.message));
      },
    );
    return completer.future;
  }

  static Future<bool> canRequestAds() async {
    return await ConsentInformation.instance.canRequestAds();
  }

  static Future<bool> isPrivacyOptionsRequired() async {
    final status =
        await ConsentInformation.instance.getPrivacyOptionsRequirementStatus();
    return status == PrivacyOptionsRequirementStatus.required;
  }

  static void showPrivacyOptionsForm() {
    ConsentForm.showPrivacyOptionsForm((formError) {
      if (formError != null) {
        debugPrint("Error showing privacy form: ${formError.message}");
      }
    });
  }
}
