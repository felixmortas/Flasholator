import 'package:flasholator/features/flashcards/domain/flashcard_pair_mutation_result.dart';

final class DataTableState {
  const DataTableState._({this.isMutating = false, this.result, this.error});
  const DataTableState.initial() : this._();
  const DataTableState.mutating() : this._(isMutating: true);
  const DataTableState.result(FlashcardPairMutationResult result) : this._(result: result);
  const DataTableState.error(Object error) : this._(error: error);
  final bool isMutating;
  final FlashcardPairMutationResult? result;
  final Object? error;
}
