import 'package:drift/drift.dart' show Value; // IMPORTANT: Importer Value de Drift

import 'package:flasholator/core/services/sm_two.dart';
import 'package:flasholator/core/services/db_wrapper.dart'; // IMPORTANT: Importer db_wrapper.dart

class Flashcard {
  int? id;
  String front;
  String back;
  String sourceLang;
  String targetLang;
  DateTime addedDate;
  int? quality;
  double easiness;
  int interval;
  int repetitions;
  int timesReviewed;
  DateTime? lastReviewDate;
  DateTime? nextReviewDate;

  Flashcard({
    required this.front,
    required this.back,
    required this.sourceLang,
    required this.targetLang,
    required this.addedDate,
    this.id,
    this.quality,
    this.easiness = 2.5,
    this.interval = 1,
    this.repetitions = 0,
    this.timesReviewed = 0,
    this.lastReviewDate,
    this.nextReviewDate,
  });

  factory Flashcard.fromDrift(FlashcardData data) {
    return Flashcard(
      id: data.id,
      front: data.front,
      back: data.back,
      sourceLang: data.sourceLang,
      targetLang: data.targetLang,
      addedDate: data.addedDate,
      quality: data.quality,
      easiness: data.easiness,
      interval: data.interval,
      repetitions: data.repetitions,
      timesReviewed: data.timesReviewed,
      lastReviewDate: data.lastReviewDate,
      nextReviewDate: data.nextReviewDate,
    );
  }

  FlashcardsCompanion toDriftCompanion() {
    return FlashcardsCompanion(
      id: id != null ? Value(id!) : const Value.absent(),
      front: Value(front),
      back: Value(back),
      sourceLang: Value(sourceLang),
      targetLang: Value(targetLang),
      addedDate: Value(addedDate),
      quality: quality != null ? Value(quality!) : const Value.absent(),
      easiness: Value(easiness),
      interval: Value(interval),
      repetitions: Value(repetitions),
      timesReviewed: Value(timesReviewed),
      lastReviewDate: lastReviewDate != null ? Value(lastReviewDate!) : const Value.absent(),
      nextReviewDate: nextReviewDate != null ? Value(nextReviewDate!) : const Value.absent(),
    );
  }

  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(
      id: map['id'],
      front: map['front'],
      back: map['back'],
      sourceLang: map['sourceLang'],
      targetLang: map['targetLang'],
      addedDate: map['addedDate'],
      quality: map['quality'],
      easiness: map['easiness'],
      interval: map['interval'],
      repetitions: map['repetitions'],
      timesReviewed: map['timesReviewed'],
      lastReviewDate: map['lastReviewDate'],
      nextReviewDate: map['nextReviewDate'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'front': front,
      'back': back,
      'sourceLang': sourceLang,
      'targetLang': targetLang,
      'addedDate': addedDate,
      'quality': quality,
      'easiness': easiness,
      'interval': interval,
      'repetitions': repetitions,
      'timesReviewed': timesReviewed,
      'lastReviewDate': lastReviewDate,
      'nextReviewDate': nextReviewDate,
    };
  }

  void review(int quality) {
    this.quality = quality;

    final smTwo = repetitions == 0
        ? SMTwo.firstReview(quality)
        : SMTwo(
                easiness: easiness,
                interval: interval,
                repetitions: repetitions)
            .review(quality);

    easiness = smTwo.easiness;
    interval = smTwo.interval;
    repetitions = smTwo.repetitions;
    timesReviewed += 1;
    lastReviewDate = DateTime.now();
    nextReviewDate = quality != 2
        ? smTwo.reviewDate
        : smTwo.reviewDate.subtract(const Duration(days: 1));
  }

  bool isDue() {
    return nextReviewDate == null ||
        DateTime.now().isAfter(nextReviewDate!) ||
        DateTime.now().isAtSameMomentAs(nextReviewDate!);
  }
}
