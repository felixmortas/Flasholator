import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flasholator/config/free_plan_limits.dart';

/// Configuration de livraison, surchargeable dans un ProviderContainer de test.
final freePlanLimitsProvider = Provider<FreePlanLimits>(
  (ref) => const FreePlanLimits(),
);
