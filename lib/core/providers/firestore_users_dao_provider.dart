import 'package:flasholator/core/services/firestore_users_dao.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flasholator/core/providers/firebase_firestore_provider.dart';

final firestoreUsersDAOProvider = Provider<FirestoreUsersDAO>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return FirestoreUsersDAO(firestore: firestore);
});