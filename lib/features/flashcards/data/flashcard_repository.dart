import 'package:drift/drift.dart';
import 'package:flasholator/core/services/db_wrapper.dart';
import 'package:flasholator/features/flashcards/domain/flashcard_pair.dart';
import 'package:flasholator/features/flashcards/domain/flashcard_pair_mutation_result.dart';

abstract interface class FlashcardRepository {
  Future<FlashcardPairMutationResult> addPair(FlashcardPair pair);

  Future<FlashcardPairMutationResult> editPair({
    required FlashcardPair source,
    required FlashcardPair replacement,
  });

  Future<FlashcardPairMutationResult> deletePair(FlashcardPair pair);
}

/// Adaptateur local. Chaque décision et chaque écriture d'une paire vivent dans
/// la même transaction afin que Drift puisse restaurer le snapshot sur erreur.
final class DriftFlashcardRepository implements FlashcardRepository {
  DriftFlashcardRepository(this._database, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final AppDatabase _database;
  final DateTime Function() _clock;

  @override
  Future<FlashcardPairMutationResult> addPair(FlashcardPair pair) {
    return _database.transaction(() async {
      final matches = await _matchingCards(pair);
      if (matches.isNotEmpty) return FlashcardPairMutationResult.conflict;

      final addedDate = _clock();
      await _database.into(_database.flashcards).insert(_newCard(pair.face, addedDate));
      await _database
          .into(_database.flashcards)
          .insert(_newCard(pair.reversedFace, addedDate));
      return FlashcardPairMutationResult.applied;
    });
  }

  @override
  Future<FlashcardPairMutationResult> editPair({
    required FlashcardPair source,
    required FlashcardPair replacement,
  }) {
    return _database.transaction(() async {
      final sourceCards = await _matchingCards(source);
      final sourceValidation = _validateCompletePair(source, sourceCards);
      if (sourceValidation != null) return sourceValidation;

      if (source.key != replacement.key) {
        final replacementCards = await _matchingCards(replacement);
        if (replacementCards.isNotEmpty) return FlashcardPairMutationResult.conflict;
      }

      final forward = _singleFace(sourceCards, source.face);
      final reverse = source.face == source.reversedFace
          ? sourceCards[1]
          : _singleFace(sourceCards, source.reversedFace);
      if (forward == null || reverse == null || identical(forward, reverse)) {
        return FlashcardPairMutationResult.conflict;
      }
      final forwardUpdated = await _database.update(_database.flashcards).replace(
            forward.copyWith(
              front: replacement.face.front,
              back: replacement.face.back,
              sourceLang: replacement.face.sourceLang,
              targetLang: replacement.face.targetLang,
            ),
          );
      final reverseUpdated = await _database.update(_database.flashcards).replace(
            reverse.copyWith(
              front: replacement.reversedFace.front,
              back: replacement.reversedFace.back,
              sourceLang: replacement.reversedFace.sourceLang,
              targetLang: replacement.reversedFace.targetLang,
            ),
          );
      if (!forwardUpdated || !reverseUpdated) {
        throw StateError('La transaction n\'a pas modifié exactement deux cartes.');
      }
      return FlashcardPairMutationResult.applied;
    });
  }

  @override
  Future<FlashcardPairMutationResult> deletePair(FlashcardPair pair) {
    return _database.transaction(() async {
      final cards = await _matchingCards(pair);
      final validation = _validateCompletePair(pair, cards);
      if (validation != null) return validation;
      final ids = cards.map((card) => card.id).toList(growable: false);
      final deleted = await (_database.delete(_database.flashcards)
            ..where((table) => table.id.isIn(ids)))
          .go();
      if (deleted != 2) {
        throw StateError('La transaction n\'a pas supprimé exactement deux cartes.');
      }
      return FlashcardPairMutationResult.applied;
    });
  }

  Future<List<FlashcardData>> _matchingCards(FlashcardPair pair) async {
    final cards = await _database.select(_database.flashcards).get();
    return cards
        .where((card) => _keyFromCard(card) == pair.key)
        .toList(growable: false);
  }

  FlashcardPairMutationResult? _validateCompletePair(
    FlashcardPair pair,
    List<FlashcardData> cards,
  ) {
    if (cards.isEmpty) return FlashcardPairMutationResult.notFound;
    if (cards.any((card) => _faceFromCardOrNull(card) == null)) {
      return FlashcardPairMutationResult.conflict;
    }
    final expectedSameFace = pair.face == pair.reversedFace;
    if (cards.length != 2 ||
        (!expectedSameFace &&
            (_countFace(cards, pair.face) != 1 ||
                _countFace(cards, pair.reversedFace) != 1)) ||
        (expectedSameFace && _countFace(cards, pair.face) != 2)) {
      return FlashcardPairMutationResult.conflict;
    }
    return null;
  }

  int _countFace(List<FlashcardData> cards, FlashcardPairFace face) =>
      cards.where((card) => _faceFromCardOrNull(card) == face).length;

  FlashcardData? _singleFace(List<FlashcardData> cards, FlashcardPairFace face) {
    for (final card in cards) {
      if (_faceFromCardOrNull(card) == face) return card;
    }
    return null;
  }

  FlashcardPairKey _keyFromCard(FlashcardData card) => FlashcardPairKey.fromValues(
        front: card.front,
        back: card.back,
        sourceLang: card.sourceLang,
        targetLang: card.targetLang,
      );

  FlashcardPairFace? _faceFromCardOrNull(FlashcardData card) {
    try {
      return FlashcardPairFace(
        front: card.front,
        back: card.back,
        sourceLang: card.sourceLang,
        targetLang: card.targetLang,
      );
    } on ArgumentError {
      return null;
    }
  }

  FlashcardsCompanion _newCard(FlashcardPairFace face, DateTime addedDate) =>
      FlashcardsCompanion.insert(
        front: face.front,
        back: face.back,
        sourceLang: face.sourceLang,
        targetLang: face.targetLang,
        addedDate: addedDate,
        easiness: 2.5,
        interval: 1,
        repetitions: 0,
        timesReviewed: 0,
      );
}
