import 'package:flasholator/features/profile/profile_subscription_view_model.dart';
import 'package:flasholator/features/shared/widgets/subscribe_button.dart';
import 'package:flasholator/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Statut et actions de l'abonnement affichés dans le profil.
class ProfileSubscriptionSection extends ConsumerWidget {
  const ProfileSubscriptionSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<ProfileSubscriptionState>(profileSubscriptionViewModelProvider,
        (previous, next) {
      if (next.notice == null || next.notice == previous?.notice) return;
      final l10n = AppLocalizations.of(context)!;
      final message = switch (next.notice!) {
        ProfileSubscriptionNotice.activated => l10n.subscriptionActivated,
        ProfileSubscriptionNotice.restored => l10n.subscriptionRestored,
        ProfileSubscriptionNotice.unavailable => l10n.noPurchasesToRestore,
        ProfileSubscriptionNotice.pending => l10n.subscriptionPending,
        ProfileSubscriptionNotice.error => l10n.subscriptionCheckFailed,
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      ref.read(profileSubscriptionViewModelProvider.notifier).clearNotice();
    });

    final subscription = ref.watch(profileSubscriptionViewModelProvider);
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                subscription.isPremium ? l10n.subscribed : l10n.notSubscribed,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            if (!subscription.isPremium)
              SubscribeButton(
                onPressed: subscription.isBusy
                    ? null
                    : () => ref
                        .read(profileSubscriptionViewModelProvider.notifier)
                        .subscribe(),
              ),
          ],
        ),
        TextButton.icon(
          onPressed: subscription.isBusy
              ? null
              : () => ref
                  .read(profileSubscriptionViewModelProvider.notifier)
                  .restore(),
          icon: const Icon(Icons.restore),
          label: Text(l10n.restorePurchases),
        ),
      ],
    );
  }
}
