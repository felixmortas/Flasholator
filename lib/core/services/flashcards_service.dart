import 'package:flutter/foundation.dart';
import 'package:flasholator/core/models/flashcard.dart';
import 'package:flasholator/config/constants.dart';
import 'db_wrapper.dart';

class FlashcardsService {
  final DatabaseWrapper<Flashcard> _db =
      DatabaseWrapper<Flashcard>('flashcards_box');

  FlashcardsService() {
    _db.init();
  }

  Future<bool> canAddCard() async {
    return _db.count() < MAX_CARDS;
  }

  Future<List<Flashcard>> loadAllFlashcards() async {
    return await _db.getAll();
  }

  Future<bool> addFlashcard(
    String front,
    String back,
    String sourceLang,
    String targetLang,
  ) async {
    if (await checkIfFlashcardExists(front, back) || front.isEmpty || back.isEmpty) {
      debugPrint('Add flashcard: Skipped (exists or empty)');
      return false;
    }

    final flashcard = Flashcard(
      front: front,
      back: back,
      sourceLang: sourceLang,
      targetLang: targetLang,
    );
    final reversedFlashcard = Flashcard(
      front: back,
      back: front,
      sourceLang: targetLang,
      targetLang: sourceLang,
    );

    await _db.add(flashcard);
    await _db.add(reversedFlashcard);
    debugPrint('Added flashcards: $front/$back and $back/$front');
    return true;
  }
  
  Future<void> editFlashcard(
  String front,
  String back,
  String sourceLang,
  String targetLang,
  String newFront,
  String newBack,
  String newSourceLang,
  String newTargetLang,
) async {
  // Chercher les deux cartes (normale + inversée)
  final map = _db.toMap(); // Map<dynamic, Flashcard>
  dynamic keyMain;
  dynamic keyReversed;
  Flashcard? mainCard;
  Flashcard? reversedCard;

  map.forEach((key, value) {
    if (value.front == front &&
        value.back == back &&
        value.sourceLang == sourceLang &&
        value.targetLang == targetLang) {
      keyMain = key;
      mainCard = value;
    } else if (value.front == back &&
        value.back == front &&
        value.sourceLang == targetLang &&
        value.targetLang == sourceLang) {
      keyReversed = key;
      reversedCard = value;
    }
  });

  // Mettre à jour la carte principale si trouvée
  if (keyMain != null && mainCard != null) {
    final updatedMain = Flashcard(
      id: mainCard!.id,
      front: newFront,
      back: newBack,
      sourceLang: newSourceLang,
      targetLang: newTargetLang,
      quality: mainCard!.quality,
      easiness: mainCard!.easiness,
      interval: mainCard!.interval,
      repetitions: mainCard!.repetitions,
      timesReviewed: mainCard!.timesReviewed,
      lastReviewDate: mainCard!.lastReviewDate,
      nextReviewDate: mainCard!.nextReviewDate,
      addedDate: mainCard!.addedDate,
    );
    await _db.put(keyMain, updatedMain);
  } else {
    debugPrint('Edit flashcard: carte principale introuvable ($front/$back).');
  }

  // Mettre à jour la carte inversée si trouvée (si vous en stockez une)
  if (keyReversed != null && reversedCard != null) {
    final updatedReversed = Flashcard(
      id: reversedCard!.id,
      front: newBack,            // inversé
      back: newFront,            // inversé
      sourceLang: newTargetLang, // inversé
      targetLang: newSourceLang, // inversé
      quality: reversedCard!.quality,
      easiness: reversedCard!.easiness,
      interval: reversedCard!.interval,
      repetitions: reversedCard!.repetitions,
      timesReviewed: reversedCard!.timesReviewed,
      lastReviewDate: reversedCard!.lastReviewDate,
      nextReviewDate: reversedCard!.nextReviewDate,
      addedDate: reversedCard!.addedDate,
    );
    await _db.put(keyReversed, updatedReversed);
  } else {
    debugPrint('Edit flashcard: carte inversée introuvable ($front/$back).');
  }

  debugPrint('Edited flashcards: $front/$back -> $newFront/$newBack');
}


  Future<void> removeFlashcard(String front, String back) async {
    final keysToRemove = _db
        .toMap()
        .entries
        .where((e) =>
            (e.value.front == front && e.value.back == back) ||
            (e.value.front == back && e.value.back == front))
        .map((e) => e.key)
        .toList();

    if (keysToRemove.isNotEmpty) {
      await _db.deleteAll(keysToRemove);
      debugPrint('Removed flashcards for: $front/$back');
    }
  }

  Future<bool> checkIfFlashcardExists(String front, String back) async {
    return _db.getAll().then((cards) =>
        cards.any((c) => c.front == front && c.back == back));
  }

  /// Retourne toutes les flashcards échues, mélangées
  Future<List<Flashcard>> dueFlashcards() async {
    // Récupérer toutes les flashcards
    List<Flashcard> flashcards = await _db.getAll();

    // Filtrer celles qui sont dues
    List<Flashcard> due = flashcards.where((f) => f.isDue()).toList();

    // Mélanger la liste pour la révision
    due.shuffle();

    return due;
  }

  Future<void> review(String front, String back, int quality) async {
    // Trouver la carte à réviser via le wrapper (clé dynamique)
    dynamic keyToUpdate;
    Flashcard? flashcardToUpdate;

    _db.toMap().forEach((key, card) {
      if (card.front == front && card.back == back) {
        keyToUpdate = key;
        flashcardToUpdate = card;
      }
    });

    if (keyToUpdate != null && flashcardToUpdate != null) {
      // Appliquer l’algorithme de révision sur l’objet
      flashcardToUpdate!.review(quality);

      // Persister la carte mise à jour
      await _db.put(keyToUpdate!, flashcardToUpdate!);
      debugPrint('Reviewed flashcard: $front/$back with quality $quality');
    } else {
      debugPrint('Review flashcard: Card not found ($front/$back).');
    }
  }

}
