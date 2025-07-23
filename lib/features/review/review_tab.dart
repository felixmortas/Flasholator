import '../../l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../core/models/flashcard.dart';
import '../../core/services/flashcards_collection.dart';
import '../shared/utils/language_selection.dart';

class ReviewTab extends StatefulWidget {
  // The ReviewTab widget is a StatefulWidget because it needs to be able to update its state
  final FlashcardsCollection flashcardsCollection;
  final ValueNotifier<bool> isAllLanguagesToggledNotifier;

  const ReviewTab({
    Key? key,
    required this.flashcardsCollection,
    required this.isAllLanguagesToggledNotifier,
  }) : super(key: key);

  @override
  State<ReviewTab> createState() => ReviewTabState();
}

class ReviewTabState extends State<ReviewTab> with TickerProviderStateMixin {
  // The _ReviewTabState class is a State because it needs to be able to update its state
  List<Flashcard> dueFlashcards = [];
  late Flashcard _currentFlashcard;
  bool isResponseHidden = true;
  LanguageSelection languageSelection = LanguageSelection.getInstance();
  bool isDue = false;
  String _questionText = "";
  String _responseText = "";
  String _questionLang = "";
  String _responseLang = "";

  set currentFlashcard(Flashcard currentFlashcard) {
    _currentFlashcard = currentFlashcard;
  }

  @override
  void initState() {
    // The initState() method is called when the stateful widget is inserted into the widget tree
    super.initState();
    updateQuestionText(widget.isAllLanguagesToggledNotifier.value);
  }

  void updateSwitchState(bool newValue) {
    setState(() {
      widget.isAllLanguagesToggledNotifier.value = newValue;
    });
  }

  void updateQuestionText(bool isAllLanguagesToggledNotifier) async {
    // Get the due flashcards from the database and set the question text and translated text
    List<Flashcard> dueFlashcards =
        await widget.flashcardsCollection.dueFlashcards();

    if (dueFlashcards.isNotEmpty) {
      // Filter dueFlashcards based on languageSelection
      if (isAllLanguagesToggledNotifier) {
        dueFlashcards = dueFlashcards.toList();
      } else {
        dueFlashcards = dueFlashcards
            .where((flashcard) =>
                (flashcard.sourceLang == languageSelection.sourceLanguage &&
                    flashcard.targetLang == languageSelection.targetLanguage) ||
                (flashcard.sourceLang == languageSelection.targetLanguage &&
                    flashcard.targetLang == languageSelection.sourceLanguage))
            .toList();
      }

      if (dueFlashcards.isNotEmpty) {
        _currentFlashcard = dueFlashcards[0];
        setState(() {
          _questionText = _currentFlashcard.front;
          _questionLang = _currentFlashcard.sourceLang;
          isResponseHidden = true;
          isDue = true;
          _responseText = _currentFlashcard.back;
          _responseLang = _currentFlashcard.targetLang;
        });
      } else {
        setState(() {
          _questionText = AppLocalizations.of(context)!.noCardToReviewToday;
          _questionLang = "";
          isResponseHidden = true;
          isDue = false;
        });
      }
    } else {
      setState(() {
        _questionText = AppLocalizations.of(context)!.noCardToReviewToday;
        _questionLang = "";
        isResponseHidden = true;
        isDue = false;
      });
    }
  }

  void _displayAnswer() {
    // Display the answer to the question
    setState(() {
      isResponseHidden = false;
    });
  }

  void _onQualityButtonPress(int quality) async {
    // Update the flashcard with the quality in the database then update the question text
    await widget.flashcardsCollection
        .review(_currentFlashcard.front, _currentFlashcard.back, quality);
    updateQuestionText(widget.isAllLanguagesToggledNotifier.value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ValueListenableBuilder<bool>(
              valueListenable: widget.isAllLanguagesToggledNotifier,
              builder: (context, value, child) {
                return Switch(
                  value: value,
                  onChanged: (bool newValue) {
                    widget.isAllLanguagesToggledNotifier.value = newValue;
                    updateQuestionText(
                        widget.isAllLanguagesToggledNotifier.value);
                  },
                );
              },
            ),
            Row(
              children: [
                Text(
                  _questionLang,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Arial',
                    color: Color.fromARGB(255, 238, 220, 245),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Center(
                    child: Text(
                      _questionText,
                      style: const TextStyle(fontSize: 18.0),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 1.0,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Visibility(
                      visible: isDue,
                      child: Text(
                        _responseLang,
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Arial',
                          color: Color.fromARGB(255, 238, 220, 245),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Center(
                        child: Visibility(
                          visible: !isResponseHidden,
                          child: Text(
                            _responseText,
                            style: const TextStyle(fontSize: 18.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Expanded(
              child: Container(),
            ),
            const SizedBox(height: 16.0),
            Visibility(
              visible: isResponseHidden && isDue,
              child: ElevatedButton(
                onPressed: () async {
                  _displayAnswer();
                },
                child: Text(AppLocalizations.of(context)!.displayAnswer),
              ),
            ),
            Visibility(
              visible: !isResponseHidden,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _onQualityButtonPress(2);
                      },
                      child: Text(
                        AppLocalizations.of(context)!.again,
                        style: TextStyle(color: Colors.white),
                        softWrap: false,
                        overflow: TextOverflow.visible,
                        maxLines: 1,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Change the color here
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _onQualityButtonPress(3);
                      },
                      child: Text(
                        AppLocalizations.of(context)!.hard,
                        style: TextStyle(color: Colors.white),
                        softWrap: false,
                        overflow: TextOverflow.visible,
                        maxLines: 1,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey, // Change the color here
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _onQualityButtonPress(4);
                      },
                      child: Text(
                        AppLocalizations.of(context)!.correct,
                        style: TextStyle(color: Colors.white),
                        softWrap: false,
                        overflow: TextOverflow.visible,
                        maxLines: 1,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // Change the color here
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _onQualityButtonPress(5);
                      },
                      child: Text(
                        AppLocalizations.of(context)!.easy,
                        style: TextStyle(color: Colors.white),
                        softWrap: false,
                        overflow: TextOverflow.visible,
                        maxLines: 1,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // Change the color here
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
