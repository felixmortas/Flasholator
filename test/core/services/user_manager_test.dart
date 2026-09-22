import 'package:flasholator/core/providers/auth_service_provider.dart';
import 'package:flasholator/core/providers/firestore_users_dao_provider.dart';
import 'package:flasholator/core/providers/revenuecat_provider.dart';
import 'package:flasholator/core/providers/user_manager_provider.dart';
import 'package:flasholator/core/services/auth_service.dart';
import 'package:flasholator/core/services/firestore_users_dao.dart';
import 'package:flasholator/core/services/revenuecat_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockAuthService extends Mock implements AuthService {}

class _MockFirestoreUsersDao extends Mock implements FirestoreUsersDAO {}

class _MockRevenueCatService extends Mock implements RevenueCatService {}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

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
