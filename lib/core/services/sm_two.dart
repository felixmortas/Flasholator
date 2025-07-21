class SMTwo {
  // SuperMemo 2 algorithm
  num easiness;
  int interval;
  int repetitions;
  DateTime reviewDate;

  SMTwo({
    // Assign default values here
    required this.easiness, 
    required this.interval, 
    required this.repetitions})
      : reviewDate = DateTime.now(); // Assign default value here because the value assigned is the result of a complex commands

  factory SMTwo.firstReview(int quality, {DateTime? reviewDate, String? dateFormat}) {
    // Review the flashcard for the first time
    if (reviewDate == null) {
      reviewDate = DateTime.now();
    }

    if (dateFormat == null) {
      dateFormat = 'yyyy-MM-dd';
    }

    return SMTwo(easiness: 2.5, interval: 0, repetitions: 0).review(quality, reviewDate: reviewDate, dateFormat: dateFormat);
  }

  SMTwo review(int quality, {DateTime? reviewDate, String? dateFormat}) {
    // Review the flashcard for the second time and onwards
    if (reviewDate == null) {
      // If the reviewDate is null, assign the default value
      reviewDate = DateTime.now();
    }

    if (dateFormat == null) {
      // If the dateFormat is null, assign the default value
      dateFormat = 'yyyy-MM-dd';
    }

    if (quality < 3) {
      // If the quality is less than 3, reset the easiness and repetitions
      interval = 1;
      repetitions = 0;
    } else {
      // If the quality is 3 or more, calculate the new easiness and interval
      if (repetitions == 0) {
        interval = 1;
      } else if (repetitions == 1) {
        interval = 6;
      } else {
        interval = (interval * easiness).ceil();
      }

      repetitions += 1;
    }

    // Calculate the new easiness
    easiness += 0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02);
    if (easiness < 1.3) {
      easiness = 1.3;
    }

    // Convert the reviewDate to the next one
    reviewDate = reviewDate.add(Duration(days: interval));
    this.reviewDate = reviewDate;

    return this;
  }
}
