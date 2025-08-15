// lib/core/providers/revenuecat_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/revenuecat_service.dart';

// Service Provider
final revenueCatServiceProvider = Provider<RevenueCatService>((ref) {
  return RevenueCatService();
});