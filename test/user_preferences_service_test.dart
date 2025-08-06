import 'package:flasholator/core/services/local_user_data_notifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flasholator/core/services/user_preferences_service.dart';

void main() {
  group('UserPreferencesService', () {
    setUp(() async {
      // Set up mock SharedPreferences storage
      SharedPreferences.setMockInitialValues({});
    });

    test('UserPreferencesService saves and updates user data correctly', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Assure une base propre pour le test

      // Étape 1 : Vérifier qu'aucune donnée n'est présente au début
      expect(prefs.getBool('isSubscribed'), isNull);
      expect(prefs.getBool('canTranslate'), isNull);
      expect(prefs.getString('subscriptionDate'), isNull);
      expect(prefs.getString('subscriptionEndDate'), isNull);
      expect(prefs.getBool('userDataCached'), isNull);

      // Étape 2 : Sauvegarder des données initiales
      final initialData = {
        'isSubscribed': true,
        'canTranslate': false,
        'subscriptionDate': '2025-08-01',
        'subscriptionEndDate': '2025-09-01',
      };
      await UserPreferencesService.updateUser(initialData);

      // Vérification des données initiales
      expect(prefs.getBool('isSubscribed'), true);
      expect(prefs.getBool('canTranslate'), false);
      expect(prefs.getString('subscriptionDate'), '2025-08-01');
      expect(prefs.getString('subscriptionEndDate'), '2025-09-01');
      expect(prefs.getBool('userDataCached'), null);

      // Étape 3 : Modifier les 4 valeurs
      final updatedData = {
        'isSubscribed': false,
        'canTranslate': true,
        'subscriptionDate': '2025-10-01',
        'subscriptionEndDate': '2025-11-01',
      };
      await UserPreferencesService.updateUser(updatedData);

      // Vérification des données modifiées
      expect(prefs.getBool('isSubscribed'), false);
      expect(prefs.getBool('canTranslate'), true);
      expect(prefs.getString('subscriptionDate'), '2025-10-01');
      expect(prefs.getString('subscriptionEndDate'), '2025-11-01');
      expect(prefs.getBool('userDataCached'), null);

      // Étape 4 : Modifier une seule valeur
      final partialUpdate = {
        'canTranslate': false,
      };
      await UserPreferencesService.updateUser(partialUpdate);

      // Vérification finale
      expect(prefs.getBool('isSubscribed'), false); // inchangé
      expect(prefs.getBool('canTranslate'), false); // modifié
      expect(prefs.getString('subscriptionDate'), '2025-10-01'); // inchangé
      expect(prefs.getString('subscriptionEndDate'), '2025-11-01'); // inchangé
      expect(prefs.getBool('userDataCached'), null);

      await prefs.clear(); // Assure une base propre pour le test suivant
    });

    test('loadUserData updates notifier correctly', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Assure une base propre pour le test

      await prefs.setBool('isSubscribed', true);
      await prefs.setBool('canTranslate', false);
      await prefs.setString('subscriptionDate', '2025-08-01');
      await prefs.setString('subscriptionEndDate', '2025-09-01');

      await UserPreferencesService.loadUserData();

      final notifierValue = LocalUserDataNotifier.userDataNotifier.value;
      expect(notifierValue['isSubscribed'], true);
      expect(notifierValue['canTranslate'], false);
      expect(notifierValue['subscriptionDate'], '2025-08-01');
      expect(notifierValue['subscriptionEndDate'], '2025-09-01');

      await prefs.clear(); // Assure une base propre pour le test suivant
    });

    test('isUserDataCached returns correct value', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Assure une base propre pour le test

      expect(await UserPreferencesService.isUserDataCached(), false);

      await prefs.setBool('userDataCached', true);

      expect(await UserPreferencesService.isUserDataCached(), true);

      await prefs.clear(); // Assure une base propre pour le test suivant
    });
  });
}
