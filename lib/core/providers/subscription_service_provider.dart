import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flasholator/core/services/subscription_service.dart';

final subscriptionServiceProvider = Provider<SubscriptionService>(
  (ref) => SubscriptionService(ref),
);
