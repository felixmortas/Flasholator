import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flasholator/core/providers/auth_service_provider.dart';
import 'package:flasholator/core/providers/firestore_users_dao_provider.dart';
import 'package:flasholator/core/providers/revenuecat_provider.dart';
import 'package:flasholator/core/providers/user_manager_provider.dart';
import 'package:flasholator/core/providers/free_plan_limits_provider.dart';
import 'package:flasholator/core/providers/user_data_provider.dart';
import 'package:flasholator/config/free_plan_limits.dart';
import 'package:flasholator/core/services/auth_service.dart';
import 'package:flasholator/core/services/firestore_users_dao.dart';
import 'package:flasholator/core/services/revenuecat_service.dart';
import 'package:flasholator/core/services/user_manager.dart';
import 'package:flasholator/core/services/user_preferences_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

class _MockAuthService extends Mock implements AuthService {}

class _MockFirestoreUsersDao extends Mock implements FirestoreUsersDAO {}

class _MockRevenueCatService extends Mock implements RevenueCatService {}
// Le SDK scelle le snapshot ; le mock reste limité au résultat de data().
// ignore: subtype_of_sealed_class
class _UserDocument extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  ProviderContainer premiumContainer(_MockAuthService auth,
      _MockRevenueCatService revenueCat) => ProviderContainer(overrides: [
        authServiceProvider.overrideWithValue(auth),
        firestoreUsersDAOProvider.overrideWithValue(_MockFirestoreUsersDao()),
        revenueCatServiceProvider.overrideWithValue(revenueCat),
      ]);

  test('achat confirmé active premium sans toucher les données', () async {
    final auth = _MockAuthService();
    final revenueCat = _MockRevenueCatService();
    when(() => auth.getUserId()).thenReturn('A');
    when(() => revenueCat.presentPaywall('A'))
        .thenAnswer((_) async => PaywallResult.purchased);
    when(() => revenueCat.isSubscribed()).thenAnswer((_) async => true);
    final container = premiumContainer(auth, revenueCat);
    addTearDown(container.dispose);
    final manager = container.read(userManagerProvider)..beginSession('A', 1);
    await manager.updateLocal({'counter': 12, 'coupleLang': 'FR-EN'});

    expect(await manager.subscribeUser(), SubscriptionActionResult.activated);
    expect(container.read(isSubscribedProvider), isTrue);
    expect((await UserPreferencesService.loadUserData())['counter'], 12);
    expect((await UserPreferencesService.loadUserData())['coupleLang'], 'FR-EN');
  });

  test('restauration confirmée active premium', () async {
    final auth = _MockAuthService();
    final revenueCat = _MockRevenueCatService();
    when(() => auth.getUserId()).thenReturn('A');
    when(() => revenueCat.restorePurchases()).thenAnswer((_) async => true);
    final container = premiumContainer(auth, revenueCat);
    addTearDown(container.dispose);
    final manager = container.read(userManagerProvider)..beginSession('A', 1);
    expect(await manager.restorePurchases(), SubscriptionActionResult.activated);
    expect(container.read(isSubscribedProvider), isTrue);
  });

  test('restauration sans droit confirmé retire un ancien droit', () async {
    final auth = _MockAuthService();
    final revenueCat = _MockRevenueCatService();
    when(() => auth.getUserId()).thenReturn('A');
    when(() => revenueCat.restorePurchases()).thenAnswer((_) async => false);
    final container = premiumContainer(auth, revenueCat);
    addTearDown(container.dispose);
    final manager = container.read(userManagerProvider)..beginSession('A', 1);
    await manager.updateLocal({'isSubscribed': true, 'counter': 6});
    expect(await manager.restorePurchases(), SubscriptionActionResult.deactivated);
    expect(container.read(isSubscribedProvider), isFalse);
    expect((await UserPreferencesService.loadUserData())['counter'], 6);
  });

  test('annulation et attente ne donnent aucun droit', () async {
    final auth = _MockAuthService();
    final revenueCat = _MockRevenueCatService();
    when(() => auth.getUserId()).thenReturn('A');
    when(() => revenueCat.presentPaywall('A'))
        .thenAnswer((_) async => PaywallResult.cancelled);
    when(() => revenueCat.isSubscribed()).thenAnswer((_) async => false);
    final container = premiumContainer(auth, revenueCat);
    addTearDown(container.dispose);
    final manager = container.read(userManagerProvider)..beginSession('A', 1);
    await manager.updateLocal({'counter': 8});
    expect(await manager.subscribeUser(), SubscriptionActionResult.cancelled);
    when(() => revenueCat.presentPaywall('A'))
        .thenAnswer((_) async => PaywallResult.notPresented);
    expect(await manager.subscribeUser(), SubscriptionActionResult.pending);
    expect(container.read(isSubscribedProvider), isFalse);
    expect((await UserPreferencesService.loadUserData())['counter'], 8);
  });

  test('erreur du paywall ne confirme aucun nouveau droit', () async {
    final auth = _MockAuthService();
    final revenueCat = _MockRevenueCatService();
    when(() => auth.getUserId()).thenReturn('A');
    when(() => revenueCat.presentPaywall('A'))
        .thenAnswer((_) async => PaywallResult.error);
    final container = premiumContainer(auth, revenueCat);
    addTearDown(container.dispose);
    final manager = container.read(userManagerProvider)..beginSession('A', 1);
    expect(await manager.subscribeUser(), SubscriptionActionResult.failed);
    expect(container.read(isSubscribedProvider), isFalse);
    verifyNever(() => revenueCat.isSubscribed());
  });

  test('échec réseau garde les droits et les données', () async {
    final auth = _MockAuthService();
    final revenueCat = _MockRevenueCatService();
    when(() => auth.getUserId()).thenReturn('A');
    when(() => revenueCat.presentPaywall('A'))
        .thenAnswer((_) async => PaywallResult.purchased);
    when(() => revenueCat.isSubscribed())
        .thenAnswer((_) async => throw StateError('offline'));
    final container = premiumContainer(auth, revenueCat);
    addTearDown(container.dispose);
    final manager = container.read(userManagerProvider)..beginSession('A', 1);
    await manager.updateLocal({'isSubscribed': true, 'counter': 19});
    await expectLater(manager.subscribeUser(), throwsA(isA<StateError>()));
    expect(container.read(isSubscribedProvider), isTrue);
    expect((await UserPreferencesService.loadUserData())['counter'], 19);
  });

  test('expiration confirmée retire premium et garde les données', () async {
    final auth = _MockAuthService();
    final revenueCat = _MockRevenueCatService();
    when(() => auth.getUserId()).thenReturn('A');
    when(() => revenueCat.presentPaywall('A'))
        .thenAnswer((_) async => PaywallResult.cancelled);
    when(() => revenueCat.isSubscribed()).thenAnswer((_) async => false);
    final container = premiumContainer(auth, revenueCat);
    addTearDown(container.dispose);
    final manager = container.read(userManagerProvider)..beginSession('A', 1);
    await manager.updateLocal({'isSubscribed': true, 'counter': 19});
    expect(await manager.subscribeUser(), SubscriptionActionResult.deactivated);
    expect(container.read(isSubscribedProvider), isFalse);
    expect((await UserPreferencesService.loadUserData())['counter'], 19);
  });

  test('retour tardif de A ne donne aucun droit à B', () async {
    final auth = _MockAuthService();
    final revenueCat = _MockRevenueCatService();
    final pending = Completer<PaywallResult>();
    when(() => auth.getUserId()).thenReturn('A');
    when(() => revenueCat.presentPaywall('A')).thenAnswer((_) => pending.future);
    final container = premiumContainer(auth, revenueCat);
    addTearDown(container.dispose);
    final manager = container.read(userManagerProvider)..beginSession('A', 1);
    final purchase = manager.subscribeUser();
    manager.beginSession('B', 2);
    when(() => auth.getUserId()).thenReturn('B');
    await manager.clearSessionData(2);
    pending.complete(PaywallResult.purchased);
    expect(await purchase, SubscriptionActionResult.ignored);
    expect(container.read(isSubscribedProvider), isFalse);
    verifyNever(() => revenueCat.isSubscribed());
  });

  test('retour tardif de la confirmation de A ne modifie pas B', () async {
    final auth = _MockAuthService();
    final revenueCat = _MockRevenueCatService();
    final pending = Completer<bool>();
    when(() => auth.getUserId()).thenReturn('A');
    when(() => revenueCat.presentPaywall('A'))
        .thenAnswer((_) async => PaywallResult.purchased);
    when(() => revenueCat.isSubscribed()).thenAnswer((_) => pending.future);
    final container = premiumContainer(auth, revenueCat);
    addTearDown(container.dispose);
    final manager = container.read(userManagerProvider)..beginSession('A', 1);
    final purchase = manager.subscribeUser();
    await Future<void>.delayed(Duration.zero);
    manager.beginSession('B', 2);
    when(() => auth.getUserId()).thenReturn('B');
    await manager.clearSessionData(2);
    pending.complete(true);
    expect(await purchase, SubscriptionActionResult.ignored);
    expect(container.read(isSubscribedProvider), isFalse);
  });

  test('une ancienne confirmation ne remplace pas une restauration récente',
      () async {
    final auth = _MockAuthService();
    final revenueCat = _MockRevenueCatService();
    final oldConfirmation = Completer<bool>();
    when(() => auth.getUserId()).thenReturn('A');
    when(() => revenueCat.presentPaywall('A'))
        .thenAnswer((_) async => PaywallResult.purchased);
    when(() => revenueCat.isSubscribed())
        .thenAnswer((_) => oldConfirmation.future);
    when(() => revenueCat.restorePurchases()).thenAnswer((_) async => false);
    final container = premiumContainer(auth, revenueCat);
    addTearDown(container.dispose);
    final manager = container.read(userManagerProvider)..beginSession('A', 1);
    final oldPurchase = manager.subscribeUser();
    await Future<void>.delayed(Duration.zero);
    expect(await manager.restorePurchases(), SubscriptionActionResult.unchanged);
    oldConfirmation.complete(true);
    expect(await oldPurchase, SubscriptionActionResult.ignored);
    expect(container.read(isSubscribedProvider), isFalse);
  });

  test('une restauration tardive de A ne modifie pas B', () async {
    final auth = _MockAuthService();
    final revenueCat = _MockRevenueCatService();
    final pending = Completer<bool>();
    when(() => auth.getUserId()).thenReturn('A');
    when(() => revenueCat.restorePurchases()).thenAnswer((_) => pending.future);
    final container = premiumContainer(auth, revenueCat);
    addTearDown(container.dispose);
    final manager = container.read(userManagerProvider)..beginSession('A', 1);
    final restore = manager.restorePurchases();
    manager.beginSession('B', 2);
    when(() => auth.getUserId()).thenReturn('B');
    await manager.clearSessionData(2);
    pending.complete(true);
    expect(await restore, SubscriptionActionResult.ignored);
    expect(container.read(isSubscribedProvider), isFalse);
  });

  test('rafraîchissement au retour active puis retire le droit expiré', () async {
    final auth = _MockAuthService();
    final revenueCat = _MockRevenueCatService();
    var active = true;
    when(() => auth.getUserId()).thenReturn('A');
    when(() => revenueCat.isSubscribed()).thenAnswer((_) async => active);
    final container = premiumContainer(auth, revenueCat);
    addTearDown(container.dispose);
    final manager = container.read(userManagerProvider)..beginSession('A', 1);
    await manager.updateLocal({'counter': 5});
    expect(await manager.refreshSubscription(), SubscriptionActionResult.activated);
    expect(container.read(isSubscribedProvider), isTrue);
    active = false;
    expect(await manager.refreshSubscription(), SubscriptionActionResult.deactivated);
    expect(container.read(isSubscribedProvider), isFalse);
    expect((await UserPreferencesService.loadUserData())['counter'], 5);
  });

  ProviderContainer quotaContainer({FreePlanLimits limits = const FreePlanLimits()}) {
    final auth = _MockAuthService();
    when(() => auth.getUserId()).thenReturn('u1');
    return ProviderContainer(overrides: [
      authServiceProvider.overrideWithValue(auth),
      firestoreUsersDAOProvider.overrideWithValue(_MockFirestoreUsersDao()),
      revenueCatServiceProvider.overrideWithValue(_MockRevenueCatService()),
      freePlanLimitsProvider.overrideWithValue(limits),
    ]);
  }

  test('la 200e traduction gratuite est comptée, pas la 201e', () async {
    final container = quotaContainer();
    addTearDown(container.dispose);
    await UserPreferencesService.updateUser({'counter': 199});
    container.read(userDataProvider.notifier).update({'counter': 199});

    final manager = container.read(userManagerProvider);
    await manager.incrementCounter();
    expect(await UserPreferencesService.getCounter(), 200);
    expect(container.read(canTranslateProvider), isFalse);
    await manager.incrementCounter();
    expect(await UserPreferencesService.getCounter(), 200);
  });

  test('une limite désactivée compte encore, premium et intention périmée non',
      () async {
    final container = quotaContainer(
      limits: const FreePlanLimits(translations: null));
    addTearDown(container.dispose);
    await UserPreferencesService.updateUser({'counter': 250});
    final manager = container.read(userManagerProvider);
    await manager.incrementCounter(isCurrent: () => false);
    expect(await UserPreferencesService.getCounter(), 250);
    await manager.incrementCounter();
    expect(await UserPreferencesService.getCounter(), 251);
    container.read(userDataProvider.notifier).update({'isSubscribed': true});
    await manager.incrementCounter();
    expect(await UserPreferencesService.getCounter(), 251);
  });

  test('deux succès concurrents sont sérialisés au bord du plafond', () async {
    final container = quotaContainer();
    addTearDown(container.dispose);
    await UserPreferencesService.updateUser({'counter': 198});
    final manager = container.read(userManagerProvider);

    await Future.wait([manager.incrementCounter(), manager.incrementCounter()]);

    expect(await UserPreferencesService.getCounter(), 200);
    expect(container.read(canTranslateProvider), isFalse);
  });

  test('les couples connus sont réutilisables mais le plafond est respecté',
      () async {
    final container = quotaContainer(
      limits: const FreePlanLimits(languagePairs: 2));
    addTearDown(container.dispose);
    container.read(userDataProvider.notifier).update({'coupleLang': 'EN-FR'});
    final manager = container.read(userManagerProvider);

    expect(await manager.tryUseLanguagePair('DE', 'FR'), isTrue);
    expect(await manager.tryUseLanguagePair('ES', 'FR'), isFalse);
    expect(await manager.tryUseLanguagePair('FR', 'DE'), isTrue);
    expect(await UserPreferencesService.getUsedLanguagePairs(),
        unorderedEquals(['EN-FR', 'DE-FR']));
  });

  test('la déconnexion RevenueCat ne bloque pas la fermeture Firebase',
      () async {
    final auth = _MockAuthService();
    final firestore = _MockFirestoreUsersDao();
    final revenueCat = _MockRevenueCatService();
    when(() => revenueCat.logOut())
        .thenAnswer((_) async => throw StateError('RC indisponible'));
    when(() => auth.signOut()).thenAnswer((_) async {});

    final container = ProviderContainer(overrides: [
      authServiceProvider.overrideWithValue(auth),
      firestoreUsersDAOProvider.overrideWithValue(firestore),
      revenueCatServiceProvider.overrideWithValue(revenueCat),
    ]);
    addTearDown(container.dispose);

    await expectLater(
      container.read(userManagerProvider).signOut(),
      throwsA(isA<StateError>()),
    );

    verify(() => revenueCat.logOut()).called(1);
    verify(() => auth.signOut()).called(1);
  });

  test('inscription conserve création, nom et courriel de vérification',
      () async {
    final auth = _MockAuthService();
    when(() => auth.registerUser('a@example.com', 'secret'))
        .thenAnswer((_) async {});
    when(() => auth.updateDisplayName('Alice')).thenAnswer((_) async {});
    when(() => auth.sendEmailVerification()).thenAnswer((_) async {});
    final container = ProviderContainer(overrides: [
      authServiceProvider.overrideWithValue(auth),
      firestoreUsersDAOProvider.overrideWithValue(_MockFirestoreUsersDao()),
      revenueCatServiceProvider.overrideWithValue(_MockRevenueCatService()),
    ]);
    addTearDown(container.dispose);

    await container.read(userManagerProvider)
        .registerUser('a@example.com', 'secret', 'Alice');

    verifyInOrder([
      () => auth.registerUser('a@example.com', 'secret'),
      () => auth.updateDisplayName('Alice'),
      () => auth.sendEmailVerification(),
    ]);
  });

  test('une écriture Firestore tardive ne repeuple pas le cache de B', () async {
    final auth = _MockAuthService();
    final firestore = _MockFirestoreUsersDao();
    final pending = Completer<void>();
    when(() => auth.getUserId()).thenReturn('A');
    when(() => firestore.updateUser('A', any()))
        .thenAnswer((_) => pending.future);
    final container = ProviderContainer(overrides: [
      authServiceProvider.overrideWithValue(auth),
      firestoreUsersDAOProvider.overrideWithValue(firestore),
      revenueCatServiceProvider.overrideWithValue(_MockRevenueCatService()),
    ]);
    addTearDown(container.dispose);
    final manager = container.read(userManagerProvider);
    manager.beginSession('A', 1);
    final write = manager.updateUser({'coupleLang': 'FR-EN'});
    manager.beginSession('B', 2);
    when(() => auth.getUserId()).thenReturn('B');
    await manager.clearSessionData(2);
    pending.complete();
    await write;
    expect(await UserPreferencesService.getCoupleLang(), '');
    expect(container.read(coupleLangProvider), '');
  });

  test('le couple de langues est restauré depuis Firestore', () async {
    final auth = _MockAuthService();
    final firestore = _MockFirestoreUsersDao();
    final revenueCat = _MockRevenueCatService();
    final document = _UserDocument();
    when(() => auth.getUserId()).thenReturn('A');
    when(() => firestore.getUser('A')).thenAnswer((_) async => document);
    when(() => document.data()).thenReturn({
      'coupleLang': 'FR-EN', 'canTranslate': true,
    });
    when(() => revenueCat.isSubscribed()).thenAnswer((_) async => false);
    final container = ProviderContainer(overrides: [
      authServiceProvider.overrideWithValue(auth),
      firestoreUsersDAOProvider.overrideWithValue(firestore),
      revenueCatServiceProvider.overrideWithValue(revenueCat),
    ]);
    addTearDown(container.dispose);
    final manager = container.read(userManagerProvider);
    manager.beginSession('A', 1);
    await manager.syncLocalFromFirestore();
    await manager.syncNotifierFromCache();
    expect(container.read(coupleLangProvider), 'FR-EN');
    expect(await UserPreferencesService.getCoupleLang(), 'FR-EN');
  });

  test('un couple choisi est persisté puis restauré à la reconnexion', () async {
    final auth = _MockAuthService();
    final firestore = _MockFirestoreUsersDao();
    final revenueCat = _MockRevenueCatService();
    final document = _UserDocument();
    when(() => auth.getUserId()).thenReturn('A');
    when(() => firestore.updateUser('A', any()))
        .thenAnswer((_) async {});
    when(() => firestore.getUser('A')).thenAnswer((_) async => document);
    when(() => document.data()).thenReturn({
      'coupleLang': 'FR-EN', 'canTranslate': true,
    });
    when(() => revenueCat.isSubscribed()).thenAnswer((_) async => false);

    ProviderContainer makeContainer() => ProviderContainer(overrides: [
      authServiceProvider.overrideWithValue(auth),
      firestoreUsersDAOProvider.overrideWithValue(firestore),
      revenueCatServiceProvider.overrideWithValue(revenueCat),
    ]);

    final first = makeContainer();
    final firstManager = first.read(userManagerProvider);
    firstManager.beginSession('A', 1);
    await firstManager.setCoupleLang('FR', 'EN');
    expect(first.read(coupleLangProvider), 'FR-EN');
    first.dispose();

    final second = makeContainer();
    addTearDown(second.dispose);
    final secondManager = second.read(userManagerProvider);
    secondManager.beginSession('A', 2);
    await secondManager.clearSessionData(2);
    await secondManager.syncLocalFromFirestore();
    await secondManager.syncNotifierFromCache();
    expect(second.read(coupleLangProvider), 'FR-EN');
    verify(() => firestore.updateUser('A', any())).called(1);
  });

  test('la même identité reconnectée invalide ses anciennes mutations', () async {
    final auth = _MockAuthService();
    final firestore = _MockFirestoreUsersDao();
    final pending = Completer<void>();
    when(() => auth.getUserId()).thenReturn('A');
    when(() => firestore.updateUser('A', any()))
        .thenAnswer((_) => pending.future);
    final container = ProviderContainer(overrides: [
      authServiceProvider.overrideWithValue(auth),
      firestoreUsersDAOProvider.overrideWithValue(firestore),
      revenueCatServiceProvider.overrideWithValue(_MockRevenueCatService()),
    ]);
    addTearDown(container.dispose);
    final manager = container.read(userManagerProvider);
    manager.beginSession('A', 1);
    final oldWrite = manager.updateUser({'coupleLang': 'FR-EN'});
    manager.beginSession('A', 2);
    await manager.clearSessionData(2);
    pending.complete();
    await oldWrite;
    expect(await UserPreferencesService.getCoupleLang(), '');
  });

  test('redémarrage du même uid conserve le compteur local', () async {
    final container = quotaContainer();
    addTearDown(container.dispose);
    final manager = container.read(userManagerProvider);
    manager.beginSession('u1', 1);
    await manager.updateLocal({'counter': 37});
    manager.beginSession('u1', 2);
    await manager.clearSessionData(2);
    expect(await UserPreferencesService.getCounter(), 37);
    expect(await UserPreferencesService.getCacheOwnerUid(), 'u1');
  });

  test('A vers B purge le compteur local de A', () async {
    final auth = _MockAuthService();
    when(() => auth.getUserId()).thenReturn('A');
    final container = ProviderContainer(overrides: [
      authServiceProvider.overrideWithValue(auth),
      firestoreUsersDAOProvider.overrideWithValue(_MockFirestoreUsersDao()),
      revenueCatServiceProvider.overrideWithValue(_MockRevenueCatService()),
    ]);
    addTearDown(container.dispose);
    final manager = container.read(userManagerProvider);
    manager.beginSession('A', 1);
    await manager.updateLocal({'counter': 37});
    manager.beginSession('B', 2);
    when(() => auth.getUserId()).thenReturn('B');
    await manager.clearSessionData(2);
    expect(await UserPreferencesService.getCounter(), 0);
    expect(await UserPreferencesService.getCacheOwnerUid(), isNull);
  });

  test('un ancien cache sans uid propriétaire est purgé', () async {
    await UserPreferencesService.updateUser({'counter': 37});
    final container = quotaContainer();
    addTearDown(container.dispose);
    final manager = container.read(userManagerProvider);
    manager.beginSession('u1', 1);
    await manager.clearSessionData(1);
    expect(await UserPreferencesService.getCounter(), 0);
  });
}
