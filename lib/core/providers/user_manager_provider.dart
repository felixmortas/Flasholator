import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flasholator/core/providers/firebase_auth_provider.dart';
import 'package:flasholator/core/providers/firestore_users_dao_provider.dart';
import 'package:flasholator/core/providers/revenuecat_provider.dart';
import 'package:flasholator/core/services/user_manager.dart';

final userManagerProvider = Provider<UserManager>((ref) {
  final firestoreDAO = ref.watch(firestoreUsersDAOProvider);
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  final revenuceCatService = ref.watch(revenueCatServiceProvider);
  return UserManager(ref: ref, firestoreDAO: firestoreDAO, firebaseAuth: firebaseAuth, revenueCatService: revenuceCatService);
});
