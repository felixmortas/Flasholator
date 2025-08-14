import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';

class RevenueCatService {

  static const String _androidApiKey = 'goog_yrvYeFcZAwKnCSkdHaMeUAIUPFb';
  static const String _webApiKey = 'rcb_sb_NQccqqpXcoNQongucDBbMULZZ';

  bool _isInitialized = false;

  Future<void> initRevenueCat(String userId) async {
    if (_isInitialized) return;

    await Purchases.setLogLevel(LogLevel.debug);
    await Purchases.configure(PurchasesConfiguration(kIsWeb ? _webApiKey : _androidApiKey)..appUserID = userId);

    _isInitialized = true;
  }

  Future<CustomerInfo> getCustomerInfo() async {
    return await Purchases.getCustomerInfo();
  }

  Future<bool> isSubscribed() async {
    final customerInfo = await getCustomerInfo();
    final isActive = customerInfo.entitlements.active.containsKey("pro");
    return isActive;
  }

  Future presentPaywall(String userId) async {
    if (kIsWeb) {
      final url = Uri.parse('https://pay.rev.cat/xnwjzccdwcxdalbd/$userId');
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication, // Ouvre dans un nouvel onglet
        );
      } else {
        throw 'Impossible d\'ouvrir le lien du paywall';
      }
    } else {
      return await RevenueCatUI.presentPaywall();
    }
  }

  Future<Offerings?> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      return offerings.current != null ? offerings : null;
    } catch (e) {
      return null;
    }
  }

  Future<void> purchasePackage(Package package) async {
    try {
      await Purchases.purchasePackage(package);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> restorePurchases() async {
    try {
      await Purchases.restorePurchases();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logOut() async {
    await Purchases.logOut();
  }
}
