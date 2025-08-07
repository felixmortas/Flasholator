import 'package:flutter_riverpod/flutter_riverpod.dart';

final userDataProvider = StateNotifierProvider<UserDataNotifier, Map<String, dynamic>>(
  (ref) => UserDataNotifier(),
);

final canTranslateProvider = Provider<bool>((ref) {
  return ref.watch(userDataProvider)['canTranslate'] as bool? ?? false;
});

final isSubscribedProvider = Provider<bool>((ref) {
  return ref.watch(userDataProvider)['isSubscribed'] as bool? ?? false;
});

final subscriptionEndDateProvider = Provider<String>((ref) {
  return ref.watch(userDataProvider)['subscriptionEndDate'] as String? ?? '';
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
  String get subscriptionDate => state['subscriptionDate'] ?? '';
  String get subscriptionEndDate => state['subscriptionEndDate'] ?? '';
}
