import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flasholator/core/providers/free_plan_limits_provider.dart';

final userDataProvider =
    StateNotifierProvider<UserDataNotifier, Map<String, dynamic>>(
  (ref) => UserDataNotifier(),
);

final canTranslateProvider = Provider<bool>((ref) {
  final user = ref.watch(userDataProvider);
  return ref.watch(freePlanLimitsProvider).canTranslate(
    count: user['counter'] as int? ?? 0,
    isPremium: user['isSubscribed'] as bool? ?? false,
  );
});

final isSubscribedProvider = Provider<bool>((ref) {
  return ref.watch(userDataProvider)['isSubscribed'] as bool? ?? false;
});

final counterProvider = Provider<int>((ref) {
  return ref.watch(userDataProvider)['counter'] as int? ?? 0;
});

final coupleLangProvider = Provider<String>((ref) {
  return ref.watch(userDataProvider)['coupleLang'] as String? ?? '';
});

class UserDataNotifier extends StateNotifier<Map<String, dynamic>> {
  UserDataNotifier() : super({});

  void update(Map<String, dynamic> data) {
    state = {...state, ...data};
  }

  void clear() {
    state = {};
  }

  /// ✅ Getter public pour lire l'état actuel
  Map<String, dynamic> get current => state;

  // Getters pratiques
  bool get isSubscribed => state['isSubscribed'] ?? false;
  bool get canTranslate => state['canTranslate'] ?? false;
  int get counter => state['counter'] ?? 0;
  String get coupleLang => state['coupleLang'] ?? '';
}
