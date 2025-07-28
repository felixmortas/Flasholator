import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class ConsentManager {
  static void initialize() {
    final params = ConsentRequestParameters();

    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () {
        debugPrint("Consent info updated.");
        ConsentForm.loadAndShowConsentFormIfRequired((formError) {
          if (formError != null) {
            debugPrint("Consent form error: ${formError.message}");
          } else {
            debugPrint("Consent form loaded and shown.");
          }
        });
      },
      (FormError error) {
        debugPrint("Consent info update error: ${error.message}");
      },
    );
  }

  static Future<bool> canRequestAds() async {
    return await ConsentInformation.instance.canRequestAds();
  }

  static Future<bool> isPrivacyOptionsRequired() async {
    final status = await ConsentInformation.instance
        .getPrivacyOptionsRequirementStatus();
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
