import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

class RevenueCatService {

  static const String _apiKey = 'goog_yrvYeFcZAwKnCSkdHaMeUAIUPFb';

  Future<void> initRevenueCat(String userId) async {
    await Purchases.setLogLevel(LogLevel.debug);
    await Purchases.configure(PurchasesConfiguration(_apiKey)..appUserID = userId);
  }

  Future<CustomerInfo> getCustomerInfo() async {
    return await Purchases.getCustomerInfo();
  }

  Future<bool> isSubscribed() async {
    final customerInfo = await getCustomerInfo();
    final isActive = customerInfo.entitlements.active.containsKey("pro");
    return isActive;
  }

  Future presentPaywall() async {
    final paywallResult = await RevenueCatUI.presentPaywall();
    return paywallResult;
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
