import 'package:flasholator/core/services/firestore_users_dao.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flasholator/core/providers/firebase_firestore_provider.dart';
import 'package:flasholator/core/providers/firebase_auth_provider.dart';

final firestoreUsersDAOProvider = Provider<FirestoreUsersDAO>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final auth = ref.watch(firebaseAuthProvider); // Ajout de FirebaseAuth
  final user = auth.currentUser;

  if (user == null) {
    // Gérer le cas où l'utilisateur n'est pas connecté
    throw Exception("L'utilisateur n'est pas connecté.");
  }

  return FirestoreUsersDAO(firestore: firestore, uid: user.uid);
});