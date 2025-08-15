import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flasholator/core/providers/auth_service_provider.dart';
import 'package:flasholator/core/providers/firestore_users_dao_provider.dart';
import 'package:flasholator/core/providers/revenuecat_provider.dart';
import 'package:flasholator/core/services/user_manager.dart';

final userManagerProvider = Provider<UserManager>((ref) {
  final firestoreDAO = ref.watch(firestoreUsersDAOProvider);
  final authService = ref.watch(authServiceProvider);
  final revenueCatService = ref.watch(revenueCatServiceProvider);

  return UserManager(ref: ref, firestoreDAO: firestoreDAO, authService: authService, revenueCatService: revenueCatService);
});

