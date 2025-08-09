import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flasholator/core/services/ad_service.dart';

final adServiceProvider = Provider<AdService>((ref) {
  return AdService();
});