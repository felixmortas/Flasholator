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
}
