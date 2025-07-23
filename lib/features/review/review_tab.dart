import '../../l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../core/models/flashcard.dart';
import '../../core/services/flashcards_collection.dart';
import '../shared/utils/language_selection.dart';
import 'widgets/all_languages_switch.dart';
import 'widgets/response_buttons.dart';
import 'widgets/words_display.dart';

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
            AllLanguagesSwitch(
              isAllLanguagesToggledNotifier:
                  widget.isAllLanguagesToggledNotifier,
              onToggle: (newValue) {
                updateSwitchState(newValue);
                updateQuestionText(newValue);
              },
            ),
            WordsDisplay(
              questionLang: _questionLang,
              questionText: _questionText,
              responseLang: _responseLang,
              responseText: _responseText,
              isResponseHidden: isResponseHidden,
              isDue: isDue,
            ),
            const Spacer(),
            ResponseButtons(
              isResponseHidden: isResponseHidden,
              isDue: isDue,
              onDisplayAnswer: _displayAnswer,
              onQualityPress: _onQualityButtonPress,
            ),
          ],
        ),
      ),
    );
  }
}
