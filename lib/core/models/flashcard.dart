import 'package:intl/intl.dart';

import 'package:flasholator/core/services/sm_two.dart';

class Flashcard {
  int? id;
  String front;
  String back;
  String sourceLang;
  String targetLang;
  int? quality;
  num easiness;
  int interval;
  int repetitions;
  int timesReviewed;
  String? lastReviewDate;
  String? nextReviewDate;
  String addedDate;

  Flashcard({
    required this.front,
    required this.back,
    required this.sourceLang,
    required this.targetLang,
    this.id,
    this.quality,
    this.easiness = 2.5, // Assign default value here
    this.interval = 1, // Assign default value here
    this.repetitions = 0, // Assign default value here
    this.timesReviewed = 0, // Assign default value here
    this.lastReviewDate,
    this.nextReviewDate,
    String? addedDate,
  }) : addedDate = addedDate ??
            DateFormat('yyyy-MM-dd').format(DateTime
                .now()); // Assign default value here because the value assigned is the result of multiple commands

  factory Flashcard.fromMap(Map<String, dynamic> map) {
    // Convert a map to a Flashcard object
    return Flashcard(
      id: map['id'],
      front: map['front'],
      back: map['back'],
      sourceLang: map['sourceLang'],
      targetLang: map['targetLang'],
      quality: map['quality'],
      easiness: map['easiness'],
      interval: map['interval'],
      repetitions: map['repetitions'],
      timesReviewed: map['timesReviewed'],
      lastReviewDate: map['lastReviewDate'],
      nextReviewDate: map['nextReviewDate'],
      addedDate: map['addedDate'],
    );
  }

  Map<String, dynamic> toMap() {
    // Convert a Flashcard object to a map
    return {
      'id': id,
      'front': front,
      'back': back,
      'sourceLang': sourceLang,
      'targetLang': targetLang,
      'quality': quality,
      'easiness': easiness,
      'interval': interval,
      'repetitions': repetitions,
      'timesReviewed': timesReviewed,
      'lastReviewDate': lastReviewDate,
      'nextReviewDate': nextReviewDate,
      'addedDate': addedDate,
    };
  }

  void review(int quality) {
    // Review a flashcard with SMTwo and update it
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
    lastReviewDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    nextReviewDate = quality != 2
        ? DateFormat('yyyy-MM-dd').format(smTwo.reviewDate)
        : DateFormat('yyyy-MM-dd')
            .format(smTwo.reviewDate.subtract(const Duration(days: 1)));
  }

  bool isDue() {
    // Check if a flashcard is due for review
    return lastReviewDate == null ||
        DateTime.now().isAfter(DateTime.parse(nextReviewDate!)) ||
        DateTime.now().isAtSameMomentAs(DateTime.parse(nextReviewDate!));
  }
}
