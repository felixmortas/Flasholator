import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flasholator/core/providers/auth_service_provider.dart';
import 'package:flasholator/core/providers/user_manager_provider.dart';
import 'package:flasholator/core/services/auth_service.dart';
import 'package:flasholator/core/services/user_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flasholator/features/shared/utils/language_selection.dart';

enum AuthSessionStatus { loading, signedOut, verificationPending, ready, error }

class AuthSessionState {
  const AuthSessionState(this.status,
      {this.account, this.error, this.generation = 0});

  final AuthSessionStatus status;
  final AuthAccount? account;
  final Object? error;
  final int generation;
}

class AuthAccount {
  const AuthAccount({required this.uid, required this.email,
    required this.emailVerified});

  final String uid;
  final String? email;
  final bool emailVerified;

  factory AuthAccount.fromFirebase(User user) => AuthAccount(
        uid: user.uid,
        email: user.email,
        emailVerified: user.emailVerified,
      );
}

/// Possède la session Firebase et attend le profil et les droits avant l'accueil.
class AuthSessionRepository extends StateNotifier<AuthSessionState> {
  AuthSessionRepository(this._auth, this._manager)
      : super(const AuthSessionState(AuthSessionStatus.loading)) {
    _subscription = _auth.authStateChanges().listen(
      (user) {
        if (!_signingOut) {
          unawaited(_accept(user).catchError((Object _) {}));
        }
      },
      onError: (Object error, StackTrace stack) {
        unawaited(_handleStreamError(error));
      },
    );
  }

  final AuthService _auth;
  final UserManager _manager;
  late final StreamSubscription<User?> _subscription;
  int _generation = 0;
  String? _pendingUid;
  Future<void>? _pendingHydration;
  Future<void> _purge = Future<void>.value();
  bool _signingOut = false;

  Future<void> _handleStreamError(Object error) async {
    final generation = ++_generation;
    _manager.beginSession(null, generation);
    LanguageSelection.getInstance().reset();
    _pendingUid = null;
    _pendingHydration = null;
    if (mounted) {
      state = AuthSessionState(AuthSessionStatus.loading,
          generation: generation);
    }
    try {
      await _clearFor(generation);
    } catch (_) {
      // L'erreur initiale du flux reste celle présentée à l'utilisateur.
    }
    if (mounted && generation == _generation) {
      state = AuthSessionState(AuthSessionStatus.error,
          error: error, generation: generation);
    }
  }

  Future<void> _clearFor(int generation) {
    final purge = _purge.then((_) => _manager.clearSessionData(generation));
    _purge = purge.catchError((Object _) {});
    return purge;
  }

  Future<void> _accept(User? user, {bool force = false}) async {
    if (!mounted) return;
    if (user == null) {
      final generation = ++_generation;
      _manager.beginSession(null, generation);
      LanguageSelection.getInstance().reset();
      _pendingUid = null;
      _pendingHydration = null;
      state = AuthSessionState(AuthSessionStatus.loading,
          generation: generation);
      try {
        await _clearFor(generation);
      } catch (error) {
        if (mounted && generation == _generation) {
          state = AuthSessionState(AuthSessionStatus.error,
              error: error, generation: generation);
        }
        rethrow;
      }
      if (mounted) {
        if (generation == _generation) {
          state = AuthSessionState(AuthSessionStatus.signedOut,
              generation: generation);
        }
      }
      return;
    }
    final account = AuthAccount.fromFirebase(user);
    if (!account.emailVerified) {
      final generation = ++_generation;
      _manager.beginSession(account.uid, generation);
      LanguageSelection.getInstance().reset();
      _pendingUid = null;
      _pendingHydration = null;
      state = AuthSessionState(AuthSessionStatus.loading,
          account: account, generation: generation);
      try {
        await _clearFor(generation);
        if (mounted && generation == _generation) {
          state = AuthSessionState(AuthSessionStatus.verificationPending,
              account: account, generation: generation);
        }
      } catch (error) {
        if (mounted && generation == _generation) {
          state = AuthSessionState(AuthSessionStatus.error,
              account: account, error: error, generation: generation);
        }
        rethrow;
      }
      return;
    }
    if (!force &&
        state.status == AuthSessionStatus.ready &&
        state.account?.uid == account.uid) {
      return;
    }
    if (!force && _pendingUid == account.uid && _pendingHydration != null) {
      return _pendingHydration!;
    }
    final generation = ++_generation;
    _manager.beginSession(account.uid, generation);
    LanguageSelection.getInstance().reset();
    _pendingUid = account.uid;
    state = AuthSessionState(AuthSessionStatus.loading,
        account: account, generation: generation);
    final hydration = () async {
      try {
        await _clearFor(generation);
        if (!mounted || generation != _generation) return;
        await _manager.initRevenueCat();
        if (!mounted || generation != _generation) return;
        await _manager.syncLocalFromFirestore();
        if (!mounted || generation != _generation) return;
        await _manager.syncNotifierFromCache();
        if (mounted && generation == _generation) {
          state = AuthSessionState(AuthSessionStatus.ready,
              account: account, generation: generation);
        }
      } catch (error) {
        if (mounted && generation == _generation) {
          state = AuthSessionState(AuthSessionStatus.error,
              account: account, error: error, generation: generation);
        }
        rethrow;
      } finally {
        if (generation == _generation) {
          _pendingUid = null;
          _pendingHydration = null;
        }
      }
    }();
    _pendingHydration = hydration;
    return hydration;
  }

  Future<void> login(String email, String password) async {
    await _auth.login(email, password);
    await _accept(_auth.currentUser);
  }

  Future<void> register(String email, String password, String name) =>
      _manager.registerUser(email, password, name);

  Future<bool> checkVerification() async {
    final uid = state.account?.uid;
    final generation = _generation;
    if (uid == null || state.status != AuthSessionStatus.verificationPending) {
      return false;
    }
    final verified = await _manager.isEmailVerified();
    if (!mounted || generation != _generation ||
        state.account?.uid != uid || _auth.currentUser?.uid != uid) {
      return false;
    }
    if (verified) {
      await _manager.updateUser({'canTranslate': true});
      if (!mounted || generation != _generation ||
          state.account?.uid != uid || _auth.currentUser?.uid != uid) {
        return false;
      }
      await _accept(_auth.currentUser, force: true);
    }
    return verified;
  }

  Future<void> resendVerification() => _manager.sendEmailVerification();
  Future<void> resetPassword(String email) =>
      _manager.sendPasswordResetEmail(email);
  Future<void> signOut() async {
    if (_signingOut) return;
    _signingOut = true;
    final generation = ++_generation;
    _manager.beginSession(null, generation);
    LanguageSelection.getInstance().reset();
    _pendingUid = null;
    _pendingHydration = null;
    state = AuthSessionState(AuthSessionStatus.loading,
        generation: generation);
    final purge = _clearFor(generation);
    Object? failure;
    StackTrace? failureStack;
    try {
      await _manager.signOut();
    } catch (error, stack) {
      failure = error;
      failureStack = stack;
    }
    try {
      await purge;
    } catch (error, stack) {
      failure ??= error;
      failureStack ??= stack;
    }
    _signingOut = false;
    await _accept(_auth.currentUser);
    if (failure != null) Error.throwWithStackTrace(failure, failureStack!);
  }
  String get userEmail => _manager.getUserEmail();
  AuthSessionState get session => state;
  Future<void> retry() => _accept(_auth.currentUser, force: true);

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final authSessionRepositoryProvider =
    StateNotifierProvider<AuthSessionRepository, AuthSessionState>((ref) {
  return AuthSessionRepository(
    ref.watch(authServiceProvider),
    ref.watch(userManagerProvider),
  );
});
