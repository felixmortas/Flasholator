import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flasholator/core/providers/firebase_auth_provider.dart';
import 'package:flasholator/core/providers/firestore_users_dao_provider.dart';
import 'package:flasholator/core/services/subscription_service.dart';

final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  final firestoreDAO = ref.watch(firestoreUsersDAOProvider);
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return SubscriptionService(ref: ref, firestoreDAO: firestoreDAO, firebaseAuth: firebaseAuth);
});
