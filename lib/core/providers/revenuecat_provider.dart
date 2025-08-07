// lib/core/providers/revenuecat_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../services/revenuecat_service.dart';

// Service Provider
final revenueCatServiceProvider = Provider<RevenueCatService>((ref) {
  return RevenueCatService();
});

// Customer Info Provider (async)
final customerInfoProvider = FutureProvider<CustomerInfo>((ref) async {
  final service = ref.read(revenueCatServiceProvider);
  return await service.getCustomerInfo();
});

// Offerings Provider (async)
final offeringsProvider = FutureProvider<Offerings?>((ref) async {
  final service = ref.read(revenueCatServiceProvider);
  return await service.getOfferings();
});
