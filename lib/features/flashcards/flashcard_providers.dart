import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flasholator/core/services/db_wrapper.dart';
import 'package:flasholator/features/flashcards/application/flashcard_collection_projections.dart';
import 'package:flasholator/features/flashcards/data/flashcard_repository.dart';
import 'package:flasholator/features/flashcards/domain/flashcard_collection.dart';

/// Dépendance locale surchargeable par les consommateurs et les tests.
final flashcardRepositoryProvider = Provider<FlashcardRepository>((ref) {
  final database = AppDatabase();
  final repository = DriftFlashcardRepository(database);
  ref.onDispose(() {
    unawaited(repository.dispose().whenComplete(database.close));
  });
  return repository;
});

/// Collection locale partagée : tous les lecteurs observent une même version.
final flashcardCollectionProvider = StreamProvider<FlashcardCollectionSnapshot>((ref) {
  return ref.watch(flashcardRepositoryProvider).watchCollection();
});

/// Horloge surchargeable pour conserver les projections de révision déterministes.
final flashcardClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final flashcardReviewProjectionProvider = Provider<AsyncValue<FlashcardReviewProjection>>((ref) {
  final now = ref.watch(flashcardClockProvider)();
  return ref.watch(flashcardCollectionProvider).whenData(
        (snapshot) => FlashcardCollectionProjections.review(snapshot, now: now),
      );
});

final flashcardTableProjectionProvider = Provider<AsyncValue<FlashcardTableProjection>>((ref) {
  return ref.watch(flashcardCollectionProvider).whenData(FlashcardCollectionProjections.table);
});

final flashcardStatisticsProjectionProvider = Provider<AsyncValue<FlashcardStatisticsProjection>>((ref) {
  return ref.watch(flashcardCollectionProvider).whenData(FlashcardCollectionProjections.statistics);
});
