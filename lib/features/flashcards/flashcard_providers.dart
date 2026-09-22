import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flasholator/core/services/db_wrapper.dart';
import 'package:flasholator/features/flashcards/data/flashcard_repository.dart';

/// Dépendance locale surchargeable par les consommateurs et les tests.
final flashcardRepositoryProvider = Provider<FlashcardRepository>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return DriftFlashcardRepository(database);
});
