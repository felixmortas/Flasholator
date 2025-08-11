import 'package:flutter_riverpod/flutter_riverpod.dart';

final userDataProvider = StateNotifierProvider<UserDataNotifier, Map<String, dynamic>>(
  (ref) => UserDataNotifier(),
);

final canTranslateProvider = Provider<bool>((ref) {
  return ref.watch(userDataProvider)['canTranslate'] as bool? ?? true;
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
