import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:flasholator/features/flashcards/data/flashcard_repository.dart';
import 'package:flasholator/features/flashcards/domain/flashcard_collection.dart';
import 'package:flasholator/features/flashcards/domain/flashcard_pair.dart';
import 'package:flasholator/features/flashcards/domain/flashcard_pair_mutation_result.dart';
import 'package:flasholator/features/flashcards/domain/flashcard_review_result.dart';
import 'package:flasholator/features/translation/application/translation_save_view_model.dart';
import 'package:flasholator/features/translation/application/translation_session_context.dart';
import 'package:flasholator/features/translation/domain/translation_result.dart';

final class _FakeFlashcardRepository implements FlashcardRepository {
  _FakeFlashcardRepository(this.onAdd);

  final Future<FlashcardPairMutationResult> Function(FlashcardPair) onAdd;
  final added = <FlashcardPair>[];

  @override
  Future<FlashcardPairMutationResult> addPair(FlashcardPair pair) {
    added.add(pair);
    return onAdd(pair);
  }

  @override
  Future<FlashcardPairMutationResult> deletePair(FlashcardPair pair) async =>
      FlashcardPairMutationResult.applied;

  @override
  Future<FlashcardPairMutationResult> editPair({
    required FlashcardPair source,
    required FlashcardPair replacement,
  }) async => FlashcardPairMutationResult.applied;

  @override
  Future<FlashcardCollectionSnapshot> loadCollection() =>
      throw UnimplementedError();

  @override
  Future<FlashcardReviewResult> reviewCard({
    required int id,
    required int quality,
  }) => throw UnimplementedError();

  @override
  Stream<FlashcardCollectionSnapshot> watchCollection() => const Stream.empty();
}

const _result = TranslationResult(
  sourceText: 'hello',
  text: 'bonjour',
  sourceLanguage: 'EN',
  targetLanguage: 'FR',
);

void main() {
  test('enregistre une unique paire depuis le résultat courant', () async {
    final repository = _FakeFlashcardRepository(
        (_) async => FlashcardPairMutationResult.applied);
    final viewModel = TranslationSaveViewModel(
      repository,
      () => const TranslationSessionContext(sessionId: 'u1', generation: 1),
    );

    final result = await viewModel.save(result: _result, isCurrent: () => true);

    expect(result, FlashcardPairMutationResult.applied);
    expect(repository.added, hasLength(1));
    expect(repository.added.single.face.front, 'Hello');
    expect(repository.added.single.face.back, 'Bonjour');
  });

  test('ignore la fin d’une sauvegarde devenue périmée', () async {
    final completion = Completer<FlashcardPairMutationResult>();
    final repository = _FakeFlashcardRepository((_) => completion.future);
    var current = true;
    final viewModel = TranslationSaveViewModel(
      repository,
      () => const TranslationSessionContext(sessionId: 'u1', generation: 1),
    );

    final command = viewModel.save(result: _result, isCurrent: () => current);
    current = false;
    completion.complete(FlashcardPairMutationResult.applied);

    expect(await command, isNull);
    expect(viewModel.state.result, isNull);
    expect(viewModel.state.error, isNull);
  });

  test('ignore une sauvegarde terminée après un changement de session',
      () async {
    final completion = Completer<FlashcardPairMutationResult>();
    final repository = _FakeFlashcardRepository((_) => completion.future);
    var session = const TranslationSessionContext(sessionId: 'u1', generation: 1);
    final viewModel = TranslationSaveViewModel(repository, () => session);

    final command = viewModel.save(result: _result, isCurrent: () => true);
    session = const TranslationSessionContext(sessionId: 'u2', generation: 2);
    completion.complete(FlashcardPairMutationResult.applied);

    expect(await command, isNull);
    expect(viewModel.state.result, isNull);
  });

  test('expose une erreur de sauvegarde sans succès artificiel', () async {
    final repository =
        _FakeFlashcardRepository((_) async => throw StateError('échec'));
    final viewModel = TranslationSaveViewModel(
      repository,
      () => const TranslationSessionContext(sessionId: 'u1', generation: 1),
    );

    expect(await viewModel.save(result: _result, isCurrent: () => true), isNull);
    expect(viewModel.state.error, isA<StateError>());
    expect(viewModel.state.result, isNull);
  });
}
