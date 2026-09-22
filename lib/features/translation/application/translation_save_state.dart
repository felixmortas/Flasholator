import 'package:flasholator/features/flashcards/domain/flashcard_pair_mutation_result.dart';

/// Etat immutable de la commande d'enregistrement, distinct de la requête DeepL.
final class TranslationSaveState {
  const TranslationSaveState._({this.isSaving = false, this.result, this.error});

  const TranslationSaveState.initial() : this._();
  const TranslationSaveState.saving() : this._(isSaving: true);
  const TranslationSaveState.result(FlashcardPairMutationResult result)
      : this._(result: result);
  const TranslationSaveState.error(Object error) : this._(error: error);

  final bool isSaving;
  final FlashcardPairMutationResult? result;
  final Object? error;
}
