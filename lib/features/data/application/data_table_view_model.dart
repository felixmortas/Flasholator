import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flasholator/features/data/application/data_table_state.dart';
import 'package:flasholator/features/flashcards/data/flashcard_repository.dart';
import 'package:flasholator/features/flashcards/domain/flashcard_pair.dart';
import 'package:flasholator/features/flashcards/domain/flashcard_pair_mutation_result.dart';

final class DataTableViewModel extends StateNotifier<DataTableState> {
  DataTableViewModel(this._repository) : super(const DataTableState.initial());
  final FlashcardRepository _repository;

  Future<FlashcardPairMutationResult?> add(FlashcardPair pair) =>
      _run(() => _repository.addPair(pair));
  Future<FlashcardPairMutationResult?> edit({required FlashcardPair source, required FlashcardPair replacement}) =>
      _run(() => _repository.editPair(source: source, replacement: replacement));
  Future<FlashcardPairMutationResult?> delete(FlashcardPair pair) =>
      _run(() => _repository.deletePair(pair));

  Future<FlashcardPairMutationResult?> _run(Future<FlashcardPairMutationResult> Function() action) async {
    if (!mounted) return null;
    state = const DataTableState.mutating();
    try {
      final result = await action();
      if (!mounted) return null;
      state = DataTableState.result(result);
      return result;
    } catch (error) {
      if (!mounted) return null;
      state = DataTableState.error(error);
      return null;
    }
  }
}
