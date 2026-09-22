import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb, visibleForTesting;
import 'package:url_launcher/url_launcher.dart';

class RevenueCatService {
  RevenueCatService({
    Future<void> Function(String userId)? configure,
    Future<void> Function(String userId)? logIn,
    Future<void> Function()? logOut,
  })  : _configureClient = configure,
        _logInClient = logIn,
        _logOutClient = logOut;

  final Future<void> Function(String userId)? _configureClient;
  final Future<void> Function(String userId)? _logInClient;
  final Future<void> Function()? _logOutClient;
  static const String _androidApiKey = 'goog_yrvYeFcZAwKnCSkdHaMeUAIUPFb';
  static const String _webApiKey = 'rcb_sb_NQccqqpXcoNQongucDBbMULZZ';

  static Future<void>? _configuration;
  static String? _activeUserId;
  static Future<void> _identityQueue = Future<void>.value();

  static Future<void> _queueIdentity(Future<void> Function() operation) {
    final result = _identityQueue.then((_) => operation());
    _identityQueue = result.catchError((Object _) {});
    return result;
  }

  Future<void> initRevenueCat(String userId) => _queueIdentity(() async {
    if (_configuration == null) {
      final configuration = _configure(userId);
      _configuration = configuration;
      try {
        await configuration;
        _activeUserId = userId;
      } catch (_) {
        _configuration = null;
        _activeUserId = null;
        rethrow;
      }
      return;
    }

    await _configuration;
    if (_activeUserId != userId) {
      final logInClient = _logInClient;
      if (logInClient != null) {
        await logInClient(userId);
      } else {
        await Purchases.logIn(userId);
      }
      _activeUserId = userId;
    }
  });

  Future<void> _configure(String userId) async {
    final configureClient = _configureClient;
    if (configureClient != null) {
      await configureClient(userId);
      return;
    }
    await Purchases.setLogLevel(LogLevel.debug);
    await Purchases.configure(
        PurchasesConfiguration(kIsWeb ? _webApiKey : _androidApiKey)
          ..appUserID = userId);
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

  Future<void> logOut() => _queueIdentity(() async {
    // Un compte Firebase non vérifié peut être déconnecté avant toute
    // configuration RevenueCat.
    if (_configuration == null) return;
    await _configuration;
    if (_activeUserId == null) return;
    final logOutClient = _logOutClient;
    if (logOutClient != null) {
      await logOutClient();
    } else {
      await Purchases.logOut();
    }
    _activeUserId = null;
  });

  @visibleForTesting
  static void resetForTesting() {
    _configuration = null;
    _activeUserId = null;
    _identityQueue = Future<void>.value();
  }
}
