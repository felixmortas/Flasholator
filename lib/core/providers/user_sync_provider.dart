// providers/user_sync_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userSyncStateProvider = StateProvider<bool>((ref) => false);