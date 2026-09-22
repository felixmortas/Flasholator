import 'dart:async';

import 'package:flasholator/features/flashcards/data/flashcard_repository.dart';
import 'package:flasholator/features/flashcards/domain/flashcard_collection.dart';
import 'package:flasholator/features/flashcards/domain/flashcard_pair.dart';
import 'package:flasholator/features/flashcards/domain/flashcard_pair_mutation_result.dart';
import 'package:flasholator/features/flashcards/domain/flashcard_review_result.dart';
import 'package:flasholator/features/review/application/review_state.dart';
import 'package:flasholator/features/review/application/review_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

final class _Repository implements FlashcardRepository {
  _Repository(
    this.snapshot, {
    this.scoreCompleter,
    this.fail = false,
    this.result = FlashcardReviewResult.applied,
  });
  FlashcardCollectionSnapshot snapshot;
  final Completer<void>? scoreCompleter;
  final bool fail;
  final FlashcardReviewResult result;
  var scoreCount = 0;

  @override
  Future<FlashcardCollectionSnapshot> loadCollection() async => snapshot;
  @override
  Stream<FlashcardCollectionSnapshot> watchCollection() =>
      Stream.value(snapshot);
  @override
  Future<FlashcardPairMutationResult> addPair(FlashcardPair pair) async =>
      FlashcardPairMutationResult.applied;
  @override
  Future<FlashcardPairMutationResult> deletePair(FlashcardPair pair) async =>
      FlashcardPairMutationResult.applied;
  @override
  Future<FlashcardPairMutationResult> editPair(
          {required FlashcardPair source,
          required FlashcardPair replacement}) async =>
      FlashcardPairMutationResult.applied;
  @override
  Future<FlashcardReviewResult> reviewCard(
      {required int id, required int quality}) async {
    scoreCount++;
    await scoreCompleter?.future;
    if (fail) throw StateError('échec');
    if (result == FlashcardReviewResult.applied) {
      snapshot = FlashcardCollectionSnapshot(
          version: snapshot.version + 1, cards: const []);
    }
    return result;
  }
}

FlashcardCollectionSnapshot _due() =>
    FlashcardCollectionSnapshot(version: 0, cards: [
      PersistedFlashcard(
        id: 9,
        front: 'bonjour',
        back: 'hello',
        sourceLang: 'FR',
        targetLang: 'EN',
        addedDate: DateTime.utc(2026),
        quality: null,
        easiness: 2.5,
        interval: 1,
        repetitions: 0,
        timesReviewed: 0,
        lastReviewDate: null,
        nextReviewDate: null,
      ),
    ]);

void main() {
  final now = DateTime.utc(2026, 1, 1);

  test(
      'charge une carte due, la révèle, puis produit un unique effet après score',
      () async {
    final repository = _Repository(_due());
    final viewModel = ReviewViewModel(repository, () => now);
    addTearDown(viewModel.dispose);
    await Future<void>.delayed(Duration.zero);
    expect(viewModel.state.card!.front, 'bonjour');
    expect(viewModel.state.isRevealed, isFalse);
    viewModel.reveal();
    expect(viewModel.state.isRevealed, isTrue);
    final effects = <ReviewEffect>[];
    final subscription = viewModel.effects.listen(effects.add);
    addTearDown(subscription.cancel);

    await viewModel.score(4);
    await Future<void>.delayed(Duration.zero);
    expect(repository.scoreCount, 1);
    expect(viewModel.state.card, isNull);
    expect(effects, [isA<ReviewScoreAcceptedEffect>()]);
  });

  test('ignore un second score concurrent et conserve une erreur typée',
      () async {
    final pending = Completer<void>();
    final repository = _Repository(_due(), scoreCompleter: pending);
    final viewModel = ReviewViewModel(repository, () => now);
    addTearDown(viewModel.dispose);
    await Future<void>.delayed(Duration.zero);
    viewModel.reveal();
    final first = viewModel.score(4);
    final second = viewModel.score(5);
    expect(repository.scoreCount, 1);
    pending.complete();
    await Future.wait([first, second]);
    expect(repository.scoreCount, 1);

    final failing = ReviewViewModel(_Repository(_due(), fail: true), () => now);
    addTearDown(failing.dispose);
    await Future<void>.delayed(Duration.zero);
    failing.reveal();
    await failing.score(4);
    expect(failing.state.phase, ReviewPhase.error);
    expect(failing.state.error, isA<ReviewScoreError>());
  });

  test(
      'conserve le filtre actif après un score et traite notFound comme une erreur',
      () async {
    final alternate = PersistedFlashcard(
      id: 10,
      front: 'hallo',
      back: 'hello',
      sourceLang: 'DE',
      targetLang: 'EN',
      addedDate: now,
      quality: null,
      easiness: 2.5,
      interval: 1,
      repetitions: 0,
      timesReviewed: 0,
      lastReviewDate: null,
      nextReviewDate: null,
    );
    final repository = _Repository(
      FlashcardCollectionSnapshot(
          version: 0, cards: [..._due().cards, alternate]),
    );
    final viewModel = ReviewViewModel(repository, () => now);
    addTearDown(viewModel.dispose);
    await viewModel.load(
      allLanguages: false,
      sourceLanguage: 'FR',
      targetLanguage: 'EN',
    );
    viewModel.reveal();
    await viewModel.score(4);
    expect(viewModel.state.card, isNull);

    final missing = ReviewViewModel(
      _Repository(_due(), result: FlashcardReviewResult.notFound),
      () => now,
    );
    addTearDown(missing.dispose);
    await Future<void>.delayed(Duration.zero);
    missing.reveal();
    await missing.score(4);
    expect(missing.state.error, isA<ReviewScoreError>());
  });
}
