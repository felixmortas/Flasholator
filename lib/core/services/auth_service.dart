import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth;

  AuthService({required FirebaseAuth firebaseAuth}) : _firebaseAuth = firebaseAuth;

  Future<void> updateDisplayName(String displayName) async {
    await _firebaseAuth.currentUser?.updateDisplayName(displayName);
  }

  Future<void> registerUser(String email, String password) async {
    await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  String getUserEmail() {
    return _firebaseAuth.currentUser?.email ?? '';
  }

  Future<void> reloadUser() async {
    await _firebaseAuth.currentUser?.reload();
  }

  Future<bool> isEmailVerified() async {
    return _firebaseAuth.currentUser?.emailVerified ?? false;
  }

  Future<void> sendEmailVerification() async {
    await _firebaseAuth.currentUser?.sendEmailVerification();
  }

  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
  }

  String getUserName() {
    final user = _firebaseAuth.currentUser;
    return user?.displayName ?? user?.email ?? '';
  }

  String getUserId() {
    final user = _firebaseAuth.currentUser;
    return user?.uid ?? '';
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> reauthenticateWithCredential(String password) async {
    final user = _firebaseAuth.currentUser;
    final email = user?.email;

    if (user == null || email == null) return;

    try {
      // Re-authentification
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
    } on Exception catch (e) {
      print("Error reauthenticating user: $e");
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    final user = _firebaseAuth.currentUser;

    if (user == null || user.email == null) return;

    try {
      // Re-authentification
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Mise à jour du mot de passe
      await user.updatePassword(newPassword);
    } on Exception catch (e) {
      // Gérer les erreurs
      print("Error changing password: $e");
    }
  }

  Future<void> deleteUser() async {
    await _firebaseAuth.currentUser?.delete();
  }

  Future<void> login(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    } on Exception catch (e) {
      print("Error logging in: $e");
    }
  }

  DateTime getSignupDate() {
    final user = _firebaseAuth.currentUser;
    if (user != null && user.metadata.creationTime != null) {
      return user.metadata.creationTime!;
    }
    return DateTime.now(); // Fallback to current time if creation time is not available
  }
}
