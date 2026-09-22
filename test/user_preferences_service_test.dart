import 'package:flasholator/core/services/user_preferences_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('defaults and cached preference cycle are stable', () async {
    expect(await UserPreferencesService.getCanTranslate(), isTrue);
    expect(await UserPreferencesService.getCounter(), 0);
    expect(await UserPreferencesService.getCoupleLang(), '');
    expect(await UserPreferencesService.isUserDataCached(), isFalse);
    await UserPreferencesService.updateUser(
        {'canTranslate': false, 'counter': 3, 'coupleLang': 'FR-EN'});
    expect(await UserPreferencesService.loadUserData(),
        {'canTranslate': false, 'counter': 3, 'coupleLang': 'FR-EN'});
    expect(await UserPreferencesService.isUserDataCached(), isTrue);
    await UserPreferencesService.deleteUser();
    expect(await UserPreferencesService.loadUserData(),
        {'canTranslate': true, 'counter': 0, 'coupleLang': ''});
    expect(await UserPreferencesService.isUserDataCached(), isFalse);
  });

  test('unsupported cached values fail explicitly', () async {
    await expectLater(
      UserPreferencesService.updateUser({'bad': <String>[]}),
      throwsArgumentError,
    );
  });

  test('les couples utilisés sont persistés puis effacés avec le compte', () async {
    expect(await UserPreferencesService.getUsedLanguagePairs(), isEmpty);
    await UserPreferencesService.setUsedLanguagePairs(['EN-FR', 'ES-FR']);
    expect(await UserPreferencesService.getUsedLanguagePairs(),
        ['EN-FR', 'ES-FR']);
    await UserPreferencesService.deleteUser();
    expect(await UserPreferencesService.getUsedLanguagePairs(), isEmpty);
  });

  test('la purge conserve les préférences hors session', () async {
    SharedPreferences.setMockInitialValues({'theme': 'dark'});
    await UserPreferencesService.updateUser({'counter': 4});
    await UserPreferencesService.clearUserData();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('theme'), 'dark');
    expect(await UserPreferencesService.getCounter(), 0);
  });

  test('les couples utilisés restent propres à chaque compte', () async {
    await UserPreferencesService.setUsedLanguagePairs(['FR-EN'], uid: 'A');
    await UserPreferencesService.clearUserData();
    expect(await UserPreferencesService.getUsedLanguagePairs(uid: 'B'), isEmpty);
    expect(await UserPreferencesService.getUsedLanguagePairs(uid: 'A'),
        ['FR-EN']);
  });
}
