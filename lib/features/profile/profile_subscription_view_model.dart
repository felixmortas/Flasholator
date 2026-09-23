import 'package:flasholator/core/providers/user_data_provider.dart';
import 'package:flasholator/core/providers/user_manager_provider.dart';
import 'package:flasholator/core/services/user_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ProfileSubscriptionNotice { activated, restored, unavailable, pending, error }

class ProfileSubscriptionState {
  const ProfileSubscriptionState({
    required this.isPremium,
    this.isBusy = false,
    this.notice,
  });

  final bool isPremium;
  final bool isBusy;
  final ProfileSubscriptionNotice? notice;

  ProfileSubscriptionState copyWith({
    bool? isPremium,
    bool? isBusy,
    ProfileSubscriptionNotice? notice,
    bool clearNotice = false,
  }) => ProfileSubscriptionState(
        isPremium: isPremium ?? this.isPremium,
        isBusy: isBusy ?? this.isBusy,
        notice: clearNotice ? null : notice ?? this.notice,
      );
}

class ProfileSubscriptionViewModel
    extends StateNotifier<ProfileSubscriptionState> {
  ProfileSubscriptionViewModel(this._manager, bool isPremium)
      : super(ProfileSubscriptionState(isPremium: isPremium));

  final UserManager _manager;

  void setPremium(bool value) {
    if (mounted) state = state.copyWith(isPremium: value);
  }

  Future<void> subscribe() => _run(_manager.subscribeUser, restoring: false);

  Future<void> restore() => _run(_manager.restorePurchases, restoring: true);

  Future<void> _run(Future<SubscriptionActionResult> Function() action,
      {required bool restoring}) async {
    if (state.isBusy) return;
    state = state.copyWith(isBusy: true, clearNotice: true);
    try {
      final result = await action();
      if (!mounted) return;
      final notice = switch (result) {
        SubscriptionActionResult.activated => restoring
            ? ProfileSubscriptionNotice.restored
            : ProfileSubscriptionNotice.activated,
        SubscriptionActionResult.failed => ProfileSubscriptionNotice.error,
        SubscriptionActionResult.pending => ProfileSubscriptionNotice.pending,
        SubscriptionActionResult.unchanged when restoring && state.isPremium =>
          ProfileSubscriptionNotice.restored,
        SubscriptionActionResult.unchanged when restoring && !state.isPremium =>
          ProfileSubscriptionNotice.unavailable,
        SubscriptionActionResult.deactivated when restoring =>
          ProfileSubscriptionNotice.unavailable,
        _ => null,
      };
      state = state.copyWith(isBusy: false, notice: notice);
    } catch (_) {
      if (mounted) {
        state = state.copyWith(
            isBusy: false, notice: ProfileSubscriptionNotice.error);
      }
    }
  }

  void clearNotice() {
    if (mounted) state = state.copyWith(clearNotice: true);
  }
}

final profileSubscriptionViewModelProvider = StateNotifierProvider.autoDispose<
    ProfileSubscriptionViewModel, ProfileSubscriptionState>((ref) {
  final viewModel = ProfileSubscriptionViewModel(
      ref.watch(userManagerProvider), ref.read(isSubscribedProvider));
  ref.listen<bool>(isSubscribedProvider, (_, next) => viewModel.setPremium(next));
  return viewModel;
});
