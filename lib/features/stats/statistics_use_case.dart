import 'package:flasholator/features/flashcards/application/flashcard_collection_projections.dart';
import 'package:flasholator/features/flashcards/domain/flashcard_collection.dart';

/// Calcule les statistiques depuis la même version de collection que les tables.
final class StatisticsUseCase {
  const StatisticsUseCase();

  FlashcardStatisticsProjection calculate(
    FlashcardCollectionSnapshot snapshot, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    if (startDate != null && endDate != null && startDate.isAfter(endDate)) {
      throw ArgumentError('La période statistique est inversée.');
    }
    return FlashcardCollectionProjections.statistics(
      snapshot,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
