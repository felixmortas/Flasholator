import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flasholator/features/mvvm_example/mvvm_example_repository.dart';
import 'package:flasholator/features/mvvm_example/mvvm_example_ui_state.dart';
import 'package:flasholator/features/mvvm_example/mvvm_example_view_model.dart';

/// Point de composition surchargeable de la dépendance de la feature.
final mvvmExampleRepositoryProvider = Provider<MvvmExampleRepository>((ref) {
  return LocalMvvmExampleRepository();
});

/// Point de composition surchargeable du ViewModel de la feature.
final mvvmExampleViewModelProvider =
    StateNotifierProvider<MvvmExampleViewModel, MvvmExampleUiState>((ref) {
  return MvvmExampleViewModel(ref.watch(mvvmExampleRepositoryProvider));
});
