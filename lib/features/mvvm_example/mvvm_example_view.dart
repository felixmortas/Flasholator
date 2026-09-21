import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flasholator/core/presentation/application_error.dart';
import 'package:flasholator/core/presentation/ui_phase.dart';
import 'package:flasholator/features/mvvm_example/mvvm_example_providers.dart';

/// Textes et conversion d'erreur fournis par la feature appelante.
final class MvvmExampleViewLabels {
  const MvvmExampleViewLabels({
    required this.initial,
    required this.loadAction,
    required this.errorMessage,
  });

  final String initial;
  final String loadAction;
  final String Function(ApplicationError error) errorMessage;
}

/// Vue de référence : elle rend l'état et transmet l'intention au ViewModel.
class MvvmExampleView extends ConsumerWidget {
  const MvvmExampleView({
    required this.labels,
    super.key,
  });

  final MvvmExampleViewLabels labels;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mvvmExampleViewModelProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        switch (state.phase) {
          UiPhase.initial => Text(labels.initial),
          UiPhase.loading => const CircularProgressIndicator(),
          UiPhase.data => Text(state.message!),
          UiPhase.error => Text(labels.errorMessage(state.error!)),
        },
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: state.phase == UiPhase.loading
              ? null
              : () => ref.read(mvvmExampleViewModelProvider.notifier).load(),
          child: Text(labels.loadAction),
        ),
      ],
    );
  }
}
