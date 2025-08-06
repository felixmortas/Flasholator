import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:flasholator/core/models/flashcard.dart';

class FlashcardsCollection {
  static const String _boxName = 'flashcards_box';
  late Box<Flashcard> _box;

  FlashcardsCollection() {
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    // Ouvrir (ou créer) la boîte Hive
    // Hive gère automatiquement le stockage local et le web
    _box = await Hive.openBox<Flashcard>(_boxName);
    debugPrint('Hive box initialized: $_boxName');
  }


  Future<List<Flashcard>> _loadFlashcards() async {
    // Charger tous les flashcards depuis la boîte Hive
    // Hive retourne une liste de valeurs
    return _box.values.toList();
  }

  Future<List<Flashcard>> loadAllFlashcards() async {
    return await _loadFlashcards();
  }

  Future<bool> addFlashcard(
    String front,
    String back,
    String sourceLang,
    String targetLang,
  ) async {
    if (await checkIfFlashcardExists(front, back) || front == '' || back == '') {
      debugPrint('Add flashcard: Skipped (exists or empty)');
      return false;
    }

    // Créer les flashcards
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

    // Ajouter à la boîte Hive
    // Hive attribue automatiquement une clé si vous ne spécifiez pas de `key`.
    // Pour simplifier la recherche, vous pouvez utiliser une clé composite ou un ID interne.
    // Pour cet exemple, nous laissons Hive gérer les clés, et nous utilisons `checkIfFlashcardExists` basé sur le contenu.
    await _box.add(flashcard);
    await _box.add(reversedFlashcard);
    debugPrint('Added flashcards: $front/$back and $back/$front');
    return true;
  }

  Future<void> removeFlashcard(String front, String back) async {
    // Supprimer les flashcards en parcourant la boîte
    // Hive ne supporte pas nativement les requêtes complexes comme WHERE.
    // Nous devons donc itérer.
    final List<int> keysToRemove = [];
    _box.toMap().forEach((key, flashcard) {
      if ((flashcard.front == front && flashcard.back == back) ||
          (flashcard.front == back && flashcard.back == front)) {
        keysToRemove.add(key as int); // Hive utilise des int comme clés par défaut si non spécifiés
      }
    });

    if (keysToRemove.isNotEmpty) {
      await _box.deleteAll(keysToRemove);
      debugPrint('Removed flashcards for: $front/$back');
    }
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
    // Trouver et mettre à jour les flashcards
    // Nous devons trouver les clés des deux cartes à modifier.
    int? keyToUpdate;
    int? keyToUpdateReversed;
    Flashcard? cardToUpdate;
    Flashcard? reversedCardToUpdate;

    // Parcourir la boîte pour trouver les cartes et leurs clés
    _box.toMap().forEach((key, flashcard) {
      if (flashcard.front == front &&
          flashcard.back == back &&
          flashcard.sourceLang == sourceLang &&
          flashcard.targetLang == targetLang) {
        keyToUpdate = key as int; // Hive utilise des int comme clés par défaut
        cardToUpdate = flashcard;
      } else if (flashcard.front == back &&
          flashcard.back == front &&
          flashcard.sourceLang == targetLang &&
          flashcard.targetLang == sourceLang) {
        keyToUpdateReversed = key as int;
        reversedCardToUpdate = flashcard;
      }
    });

    // Si les deux cartes sont trouvées, procéder à la mise à jour
    if (keyToUpdate != null &&
        keyToUpdateReversed != null &&
        cardToUpdate != null &&
        reversedCardToUpdate != null) {

      // Créer les nouvelles instances mises à jour pour la carte principale
      final updatedCard = Flashcard(
        id: cardToUpdate!.id, // Conserver l'ID existant
        front: newFront,
        back: newBack,
        sourceLang: newSourceLang,
        targetLang: newTargetLang,
        quality: cardToUpdate!.quality,
        easiness: cardToUpdate!.easiness,
        interval: cardToUpdate!.interval,
        repetitions: cardToUpdate!.repetitions,
        timesReviewed: cardToUpdate!.timesReviewed,
        lastReviewDate: cardToUpdate!.lastReviewDate,
        nextReviewDate: cardToUpdate!.nextReviewDate,
        addedDate: cardToUpdate!.addedDate,
      );

      // Créer les nouvelles instances mises à jour pour la carte inversée
      final updatedReversedCard = Flashcard(
        id: reversedCardToUpdate!.id,
        front: newBack, // Inverser newFront et newBack
        back: newFront,
        sourceLang: newTargetLang, // Inverser newSourceLang et newTargetLang
        targetLang: newSourceLang,
        quality: reversedCardToUpdate!.quality,
        easiness: reversedCardToUpdate!.easiness,
        interval: reversedCardToUpdate!.interval,
        repetitions: reversedCardToUpdate!.repetitions,
        timesReviewed: reversedCardToUpdate!.timesReviewed,
        lastReviewDate: reversedCardToUpdate!.lastReviewDate,
        nextReviewDate: reversedCardToUpdate!.nextReviewDate,
        addedDate: reversedCardToUpdate!.addedDate,
      );

      // Mettre à jour les deux cartes dans la boîte Hive
      // Ces opérations sont généralement atomiques dans Hive
      await _box.put(keyToUpdate!, updatedCard);
      await _box.put(keyToUpdateReversed!, updatedReversedCard);

      debugPrint('Edited flashcards: $front/$back -> $newFront/$newBack');
    } else {
      debugPrint('Edit flashcard: One or both cards not found for $front/$back.');
      // Vous pouvez choisir de lancer une exception ici si cela est préférable
      // throw Exception('Failed to find both flashcards for editing: $front/$back');
    }
  }

  // loadData est probablement redondant avec loadAllFlashcards
  // Si vous l'utilisez vraiment, vous pouvez le garder
  Future<List<Map>> loadData() async {
    // Convertir les Flashcards en Map si nécessaire
    List<Map> data = [];
    for (var flashcard in await _loadFlashcards()) {
      // Flashcard.toMap() retourne Map<String, dynamic>
      data.add(flashcard.toMap());
    }
    return data;
  }

  Future<bool> checkIfFlashcardExists(String front, String back) async {
    // Vérifier l'existence en parcourant la boîte
    for (var flashcard in _box.values) {
      if (flashcard.front == front && flashcard.back == back) {
        return true;
      }
    }
    return false;
  }

  Future<List<Flashcard>> dueFlashcards() async {
    // Obtenir les flashcards échus
    List<Flashcard> flashcards = await _loadFlashcards();
    List<Flashcard> dueFlashcards = flashcards.where((flashcard) => flashcard.isDue()).toList();
    dueFlashcards.shuffle();
    return dueFlashcards;
  }

   Future<void> review(String front, String back, int quality) async {
    // Trouver, revoir et mettre à jour le flashcard
    int? keyToUpdate;
    Flashcard? flashcardToUpdate;

    _box.toMap().forEach((key, flashcard) {
      if (flashcard.front == front && flashcard.back == back) {
        keyToUpdate = key as int;
        flashcardToUpdate = flashcard;
      }
    });

    if (keyToUpdate != null && flashcardToUpdate != null) {
      // Effectuer la révision sur l'objet
      flashcardToUpdate!.review(quality);
      // Mettre à jour dans la boîte
      await _box.put(keyToUpdate!, flashcardToUpdate!);
      debugPrint('Reviewed flashcard: $front/$back with quality $quality');
    } else {
        debugPrint('Review flashcard: Card not found ($front/$back).');
    }
  }
}