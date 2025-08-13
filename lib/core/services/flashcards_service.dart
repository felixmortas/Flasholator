import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';
import 'package:flasholator/core/models/flashcard.dart';
import 'package:flasholator/config/constants.dart';
import 'package:flasholator/core/services/db_wrapper.dart';

class FlashcardsService {
  final DatabaseWrapper _db = DatabaseWrapper();
  bool _isInitialized = false;

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await _db.init();
      _isInitialized = true;
    }
  }


  Future<bool> canAddCard() async {
    await _ensureInitialized();
    final count = await _db.count();
    return count < MAX_CARDS;

  }

  Future<List<Flashcard>> loadAllFlashcards() async {
    await _ensureInitialized();
    // 1. On récupère les données brutes de Drift (`FlashcardData`)
    final List<FlashcardData> rawData = await _db.getAll();

    // 2. On les convertit en votre modèle `Flashcard`
    // (Vous devrez implémenter cette fonction de conversion)
    return rawData.map((data) => Flashcard.fromDrift(data)).toList();

  }

  Future<bool> addFlashcard(
    String front,
    String back,
    String sourceLang,
    String targetLang,
  ) async {
    await _ensureInitialized();
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

    await _db.add(flashcard.toDriftCompanion());
    await _db.add(reversedFlashcard.toDriftCompanion());
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
    await _ensureInitialized();

    final allCards = await _db.getAll();
    
    final mainCardData = allCards.firstWhereOrNull(
      (c) => c.front == front && c.back == back,
    );
    final reversedCardData = allCards.firstWhereOrNull(
      (c) => c.front == back && c.back == front,
    );
    
    if (mainCardData != null) {
      // 1. Mettre à jour l'objet de données Drift avec .copyWith
      final updatedMainData = mainCardData.copyWith(
        front: newFront,
        back: newBack,
        sourceLang: newSourceLang,
        targetLang: newTargetLang,
      );

      // 2. Créer une instance de Flashcard à partir des données mises à jour
      final updatedMainFlashcard = Flashcard.fromDrift(updatedMainData);

      // 3. Persister en utilisant le Companion généré
      await _db.put(updatedMainFlashcard.toDriftCompanion()); 
    }

    if (reversedCardData != null) {
      // 1. Mettre à jour l'objet de données Drift avec .copyWith
      final updatedReversedData = reversedCardData.copyWith(
        front: newBack, // Inversé
        back: newFront, // Inversé
        sourceLang: newTargetLang, // Inversé
        targetLang: newSourceLang, // Inversé
      );
      
      // 2. Créer une instance de Flashcard à partir des données mises à jour
      final updatedReversedFlashcard = Flashcard.fromDrift(updatedReversedData);
      
      // 3. Persister en utilisant le Companion généré
      await _db.put(updatedReversedFlashcard.toDriftCompanion());
    }
    
    debugPrint('Edited flashcards: $front/$back -> $newFront/$newBack');
  }



  Future<void> removeFlashcard(String front, String back) async {
    await _ensureInitialized();

    // 1. Récupérer les données brutes
    final allCards = await _db.getAll();
    // 2. Filtrer pour trouver les IDs à supprimer
    final idsToRemove = allCards
        .where((c) => (c.front == front && c.back == back) || (c.front == back && c.back == front))
        .map((c) => c.id) // On ne récupère que les IDs
        .toList();

    if (idsToRemove.isNotEmpty) {
      // 3. Appeler la méthode deleteAll du wrapper avec la liste d'IDs
      await _db.deleteAll(idsToRemove);
      debugPrint('Removed flashcards for: $front/$back');
    }
  }


  Future<bool> checkIfFlashcardExists(String front, String back) async {
    await _ensureInitialized();
    // On utilise notre nouvelle méthode optimisée !
    return _db.cardExists(front, back);
  }


  /// Retourne toutes les flashcards échues, mélangées
  Future<List<Flashcard>> dueFlashcards() async {
    await _ensureInitialized();
    // On utilise notre nouvelle méthode optimisée !
    final dueData = await _db.getDueFlashcards(DateTime.now());
    dueData.shuffle();
    // On n'oublie pas de convertir le résultat en notre modèle de domaine
    return dueData.map((data) => Flashcard.fromDrift(data)).toList();
  }


  Future<void> review(String front, String back, int quality) async {
    await _ensureInitialized();
    
    // 1. Trouver la donnée brute de la carte à réviser
    final allCards = await _db.getAll();
    final cardDataToReview = allCards.firstWhereOrNull((c) => c.front == front && c.back == back);

    if (cardDataToReview != null) {
      // 2. La convertir en notre modèle de domaine pour appliquer la logique métier
      final flashcard = Flashcard.fromDrift(cardDataToReview);

      // 3. Appliquer l'algorithme de révision
      flashcard.review(quality);
      
      // 4. Utiliser la méthode `toDriftCompanion()` pour créer un objet
      //    qui peut être utilisé pour la mise à jour dans Drift.
      final updatedFlashcardCompanion = flashcard.toDriftCompanion();
      
      // 5. Persister la carte mise à jour. La méthode `put` doit accepter un Companion.
      await _db.put(updatedFlashcardCompanion);
      debugPrint('Reviewed flashcard: $front/$back with quality $quality');
    } else {
      debugPrint('Review flashcard: Card not found ($front/$back).');
    }
  }
}
