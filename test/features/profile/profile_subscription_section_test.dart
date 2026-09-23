import 'package:flasholator/core/providers/user_data_provider.dart';
import 'package:flasholator/core/providers/user_manager_provider.dart';
import 'package:flasholator/core/services/user_manager.dart';
import 'package:flasholator/features/profile/profile_subscription_section.dart';
import 'package:flasholator/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockUserManager extends Mock implements UserManager {}

void main() {
  testWidgets('restaurer les achats confirme le droit et actualise le statut',
      (tester) async {
    final manager = _MockUserManager();
    late ProviderContainer container;
    when(() => manager.restorePurchases()).thenAnswer((_) async {
      container.read(userDataProvider.notifier).update({'isSubscribed': true});
      return SubscriptionActionResult.activated;
    });
    container = ProviderContainer(overrides: [
      userManagerProvider.overrideWithValue(manager),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: ProfileSubscriptionSection()),
      ),
    ));

    expect(find.text('Subscription: Not subscribed'), findsOneWidget);
    await tester.tap(find.text('Restore purchases'));
    await tester.pump();
    await tester.pump();

    verify(() => manager.restorePurchases()).called(1);
    expect(find.text('Subscription: Subscribed'), findsOneWidget);
    expect(find.text('Subscription: Not subscribed'), findsNothing);
  });
}
