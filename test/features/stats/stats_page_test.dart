import 'package:flasholator/features/stats/stats_page.dart';
import 'package:flasholator/features/stats/stats_view_model.dart';
import 'package:flasholator/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _page(AsyncValue<StatsViewData> result) => ProviderScope(
      overrides: [statsViewDataProvider.overrideWith((ref) => result)],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: StatsPage(),
      ),
    );

void main() {
  testWidgets('rend le chargement de la collection', (tester) async {
    await tester.pumpWidget(_page(const AsyncLoading<StatsViewData>()));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('rend l’erreur de la collection', (tester) async {
    await tester.pumpWidget(
      _page(AsyncError<StatsViewData>(StateError('lecture impossible'),
          StackTrace.current)),
    );
    expect(find.textContaining('lecture impossible'), findsOneWidget);
  });
}
