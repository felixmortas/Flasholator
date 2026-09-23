import 'package:flasholator/core/providers/user_data_provider.dart';
import 'package:flasholator/core/providers/user_manager_provider.dart';
import 'package:flasholator/core/services/user_manager.dart';
import 'package:flasholator/features/profile/profile_subscription_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockUserManager extends Mock implements UserManager {}

void main() {
  test('achat confirmé et erreur sont présentés par un état typé', () async {
    final manager = _MockUserManager();
    when(() => manager.subscribeUser())
        .thenAnswer((_) async => SubscriptionActionResult.activated);
    final container = ProviderContainer(overrides: [
      userManagerProvider.overrideWithValue(manager),
    ]);
    addTearDown(container.dispose);
    final subscription = container.listen(profileSubscriptionViewModelProvider,
        (_, __) {}, fireImmediately: true);
    addTearDown(subscription.close);

    await container.read(profileSubscriptionViewModelProvider.notifier).subscribe();
    expect(container.read(profileSubscriptionViewModelProvider).notice,
        ProfileSubscriptionNotice.activated);
    when(() => manager.subscribeUser())
        .thenAnswer((_) async => SubscriptionActionResult.pending);
    await container.read(profileSubscriptionViewModelProvider.notifier).subscribe();
    expect(container.read(profileSubscriptionViewModelProvider).notice,
        ProfileSubscriptionNotice.pending);
    when(() => manager.subscribeUser()).thenThrow(StateError('offline'));
    await container.read(profileSubscriptionViewModelProvider.notifier).subscribe();
    expect(container.read(profileSubscriptionViewModelProvider).notice,
        ProfileSubscriptionNotice.error);
    expect(container.read(profileSubscriptionViewModelProvider).isBusy, isFalse);
  });

  test('restauration déjà premium confirme le droit et suit le provider',
      () async {
    final manager = _MockUserManager();
    when(() => manager.restorePurchases())
        .thenAnswer((_) async => SubscriptionActionResult.unchanged);
    final container = ProviderContainer(overrides: [
      userManagerProvider.overrideWithValue(manager),
    ]);
    addTearDown(container.dispose);
    final subscription = container.listen(profileSubscriptionViewModelProvider,
        (_, __) {}, fireImmediately: true);
    addTearDown(subscription.close);

    container.read(userDataProvider.notifier).update({'isSubscribed': true});
    expect(container.read(profileSubscriptionViewModelProvider).isPremium, isTrue);
    await container.read(profileSubscriptionViewModelProvider.notifier).restore();
    expect(container.read(profileSubscriptionViewModelProvider).notice,
        ProfileSubscriptionNotice.restored);
    container.read(userDataProvider.notifier).update({'isSubscribed': false});
    expect(container.read(profileSubscriptionViewModelProvider).isPremium, isFalse);
    await container.read(profileSubscriptionViewModelProvider.notifier).restore();
    expect(container.read(profileSubscriptionViewModelProvider).notice,
        ProfileSubscriptionNotice.unavailable);
  });
}
