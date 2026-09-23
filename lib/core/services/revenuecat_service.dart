import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb, visibleForTesting;
import 'package:url_launcher/url_launcher.dart';

class RevenueCatService {
  RevenueCatService({
    Future<void> Function(String userId)? configure,
    Future<void> Function(String userId)? logIn,
    Future<void> Function()? logOut,
    Future<PaywallResult> Function()? showPaywall,
    Future<bool> Function()? readEntitlement,
    Future<bool> Function()? restoreEntitlement,
    bool? web,
    Future<bool> Function(Uri)? canOpenPaywall,
    Future<bool> Function(Uri)? openPaywall,
  })  : _configureClient = configure,
        _logInClient = logIn,
        _logOutClient = logOut,
        _showPaywall = showPaywall,
        _readEntitlement = readEntitlement,
        _restoreEntitlement = restoreEntitlement,
        _web = web ?? kIsWeb,
        _canOpenPaywall = canOpenPaywall,
        _openPaywall = openPaywall;

  final Future<void> Function(String userId)? _configureClient;
  final Future<void> Function(String userId)? _logInClient;
  final Future<void> Function()? _logOutClient;
  final Future<PaywallResult> Function()? _showPaywall;
  final Future<bool> Function()? _readEntitlement;
  final Future<bool> Function()? _restoreEntitlement;
  final bool _web;
  final Future<bool> Function(Uri)? _canOpenPaywall;
  final Future<bool> Function(Uri)? _openPaywall;
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
    if (_readEntitlement != null) return _readEntitlement!();
    final customerInfo = await getCustomerInfo();
    return customerInfo.entitlements.active.containsKey('pro');
  }

  Future<PaywallResult> presentPaywall(String userId) async {
    if (_showPaywall != null) return _showPaywall!();
    if (_web) {
      final url = Uri.parse('https://pay.rev.cat/xnwjzccdwcxdalbd/$userId');
      if (await (_canOpenPaywall?.call(url) ?? canLaunchUrl(url))) {
        final launched = await (_openPaywall?.call(url) ?? launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        ));
        if (!launched) {
          throw StateError('Impossible d\'ouvrir le lien du paywall');
        }
        // Le paiement externe est en attente de confirmation RevenueCat.
        return PaywallResult.notPresented;
      } else {
        throw StateError('Impossible d\'ouvrir le lien du paywall');
      }
    } else {
      return RevenueCatUI.presentPaywall();
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

  Future<bool> restorePurchases() async {
    if (_restoreEntitlement != null) return _restoreEntitlement!();
    final customerInfo = await Purchases.restorePurchases();
    return customerInfo.entitlements.active.containsKey('pro');
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
