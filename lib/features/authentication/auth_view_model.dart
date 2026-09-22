import 'package:flasholator/features/authentication/auth_session_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthActionState {
  const AuthActionState({this.loading = false, this.error, this.completed = false,
    this.verified});

  final bool loading;
  final Object? error;
  final bool completed;
  final bool? verified;
}

class AuthViewModel extends StateNotifier<AuthActionState> {
  AuthViewModel(this._session) : super(const AuthActionState());

  final AuthSessionRepository _session;
  AuthActionState get action => state;
  int _request = 0;

  Future<void> _run(Future<void> Function() action) async {
    final request = ++_request;
    state = const AuthActionState(loading: true);
    try {
      await action();
      if (mounted && request == _request) {
        state = const AuthActionState(completed: true);
      }
    } catch (error) {
      if (mounted && request == _request) state = AuthActionState(error: error);
    }
  }

  Future<void> login(String email, String password) =>
      _run(() => _session.login(email, password));
  Future<void> register(String email, String password, String name) =>
      _run(() => _session.register(email, password, name));
  Future<void> resendVerification() => _run(_session.resendVerification);
  Future<void> resetPassword(String email) =>
      _run(() => _session.resetPassword(email));

  Future<void> checkVerification() async {
    final request = ++_request;
    state = const AuthActionState(loading: true);
    try {
      final verified = await _session.checkVerification();
      if (mounted && request == _request) {
        state = AuthActionState(completed: true, verified: verified);
      }
    } catch (error) {
      if (mounted && request == _request) state = AuthActionState(error: error);
    }
  }

  void clear() {
    _request++;
    state = const AuthActionState();
  }
}

final authViewModelProvider =
    StateNotifierProvider.autoDispose<AuthViewModel, AuthActionState>((ref) {
  return AuthViewModel(ref.watch(authSessionRepositoryProvider.notifier));
});
