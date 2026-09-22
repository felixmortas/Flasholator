import 'package:flutter_test/flutter_test.dart';

import 'package:flasholator/features/data/application/data_table_view_model.dart';
import 'package:flasholator/features/flashcards/data/flashcard_repository.dart';
import 'package:flasholator/features/flashcards/domain/flashcard_collection.dart';
import 'package:flasholator/features/flashcards/domain/flashcard_pair.dart';
import 'package:flasholator/features/flashcards/domain/flashcard_pair_mutation_result.dart';
import 'package:flasholator/features/flashcards/domain/flashcard_review_result.dart';

final class _Repository implements FlashcardRepository {
  _Repository(this.editResult);
  final FlashcardPairMutationResult editResult;
  FlashcardPair? source;
  FlashcardPair? replacement;

  @override
  Future<FlashcardPairMutationResult> editPair({
    required FlashcardPair source,
    required FlashcardPair replacement,
  }) async {
    this.source = source;
    this.replacement = replacement;
    return editResult;
  }

  @override
  Future<FlashcardPairMutationResult> addPair(FlashcardPair pair) =>
      throw UnimplementedError();
  @override
  Future<FlashcardPairMutationResult> deletePair(FlashcardPair pair) =>
      throw UnimplementedError();
  @override
  Future<FlashcardCollectionSnapshot> loadCollection() =>
      throw UnimplementedError();
  @override
  Future<FlashcardReviewResult> reviewCard({required int id, required int quality}) =>
      throw UnimplementedError();
  @override
  Stream<FlashcardCollectionSnapshot> watchCollection() => const Stream.empty();
}

FlashcardPair _pair(String front, String back) => FlashcardPair(
      front: front,
      back: back,
      sourceLang: 'EN',
      targetLang: 'FR',
    );

void main() {
  test('transmet une correction atomique et son conflit sans copie locale',
      () async {
    final repository = _Repository(FlashcardPairMutationResult.conflict);
    final viewModel = DataTableViewModel(repository);
    final source = _pair('hello', 'bonjour');
    final replacement = _pair('hi', 'salut');

    final result = await viewModel.edit(
      source: source,
      replacement: replacement,
    );

    expect(result, FlashcardPairMutationResult.conflict);
    expect(repository.source, source);
    expect(repository.replacement, replacement);
    expect(viewModel.state.result, FlashcardPairMutationResult.conflict);
    expect(viewModel.state.error, isNull);
  });

  test('expose une paire absente sans la modifier localement', () async {
    final repository = _Repository(FlashcardPairMutationResult.notFound);
    final viewModel = DataTableViewModel(repository);
    final source = _pair('hello', 'bonjour');

    final result = await viewModel.edit(
      source: source,
      replacement: _pair('hi', 'salut'),
    );

    expect(result, FlashcardPairMutationResult.notFound);
    expect(viewModel.state.result, FlashcardPairMutationResult.notFound);
  });
}
