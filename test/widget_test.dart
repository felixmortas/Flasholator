// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flasholator/main.dart';
import 'package:flasholator/l10n/app_localizations.dart';

void main() {
  for (final languageCode in ['fr', 'en', 'es']) {
    testWidgets('MyApp charge la localisation générée $languageCode',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MyApp(
            locale: Locale(languageCode),
            home: const Placeholder(),
          ),
        ),
      );

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      final localizations = AppLocalizations.of(
        tester.element(find.byType(Placeholder)),
      );
      expect(app.supportedLocales, contains(Locale(languageCode)));
      expect(localizations?.localeName, languageCode);
    });
  }
}
