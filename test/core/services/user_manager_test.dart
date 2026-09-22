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
import 'package:flasholator/core/services/user_preferences_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockAuthService extends Mock implements AuthService {}

class _MockFirestoreUsersDao extends Mock implements FirestoreUsersDAO {}

class _MockRevenueCatService extends Mock implements RevenueCatService {}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

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
}
