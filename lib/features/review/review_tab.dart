import 'package:flasholator/features/review/widgets/edit_answer_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

import 'package:flasholator/l10n/app_localizations.dart';
import 'package:flasholator/config/constants.dart';
import 'package:flasholator/core/providers/ad_provider.dart';
import 'package:flasholator/core/models/flashcard.dart';
import 'package:flasholator/core/providers/user_data_provider.dart';
import 'package:flasholator/core/services/flashcards_service.dart';
import 'package:flasholator/features/shared/utils/language_selection.dart';
import 'package:flasholator/features/review/review_empty_page.dart';
import 'package:flasholator/features/review/widgets/all_languages_switch.dart';
import 'package:flasholator/features/review/widgets/response_buttons.dart';
import 'package:flasholator/features/review/widgets/words_display.dart';
import 'package:flasholator/features/shared/utils/measure_child_size.dart';

class ReviewTab extends ConsumerStatefulWidget {
  // The ReviewTab widget is a StatefulWidget because it needs to be able to update its state
  final FlashcardsService flashcardsService;
  final ValueNotifier<bool> isAllLanguagesToggledNotifier;

  const ReviewTab({
    Key? key,
    required this.flashcardsService,
    required this.isAllLanguagesToggledNotifier,
  }) : super(key: key);

  @override
  ConsumerState<ReviewTab> createState() => ReviewTabState();
}

class ReviewTabState extends ConsumerState<ReviewTab> with TickerProviderStateMixin {
  // The _ReviewTabState class is a State because it needs to be able to update its state
  List<Flashcard> dueFlashcards = [];
  late Flashcard _currentFlashcard;
  bool isResponseHidden = true;
  bool isEditing = false;
  TextEditingController editingController = TextEditingController();
  int? overrideQuality; // null = normal behavior

  LanguageSelection languageSelection = LanguageSelection.getInstance();
  bool isDue = false;
  String _questionText = "";
  String _responseText = "";
  String _questionLang = "";
  String _responseLang = "";

  int adCounter = 0;

  double _overlayHeight = 0.0;

  set currentFlashcard(Flashcard currentFlashcard) {
    _currentFlashcard = currentFlashcard;
  }

  bool isCardConsumed = false;

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
        await widget.flashcardsService.dueFlashcards();

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
        _currentFlashcard = dueFlashcards[0];
        setState(() {
          isResponseHidden = true;
          isDue = true;
          _questionText = _currentFlashcard.front;
          _questionLang = _currentFlashcard.sourceLang;
          _responseText = _currentFlashcard.back;
          _responseLang = _currentFlashcard.targetLang;
          overrideQuality = null;
          editingController.clear();
        });
    } else {
      setState(() {
        _questionText = AppLocalizations.of(context)!.noCardToReviewToday;
        _questionLang = "";
        isResponseHidden = true;
        isDue = false;
        overrideQuality = null;
      });
    }
  }

  void _onQualityButtonPress(int quality) async {
    if (!ref.read(isSubscribedProvider)) {
      // Show interstitial ad if the user is not subscribed and reached certain number of reviews
      // if (adCounter % INTERSTITIAL_FREQUENCY == 0) {
      //   ref.read(adServiceProvider).showInterstitial();
      // }
      // adCounter += 1;
      
      // Show interstitial with a probability of 1/INTERSTITIAL_FREQUENCY
      if (Random().nextInt(INTERSTITIAL_FREQUENCY) == 0) {
        ref.read(adServiceProvider).showInterstitial();
      }
    }
    setState(() {
      isCardConsumed = true; // empêche d'afficher la carte actuelle à nouveau
    });

    // Update the flashcard with the quality in the database then update the question text
    await widget.flashcardsService
        .review(_currentFlashcard.front, _currentFlashcard.back, quality);
    updateQuestionText(widget.isAllLanguagesToggledNotifier.value);

    if (mounted) {
      setState(() {
        isCardConsumed = false;
      });
    }

  }

  void _evaluateWrittenAnswer() {
    final userAnswer = editingController.text.trim().toLowerCase();
    final correctAnswer = _responseText.trim().toLowerCase();

    if (userAnswer == correctAnswer) {
      // Suggérer qualité selon préférences, ou demander à l'utilisateur ?
      setState(() {
        overrideQuality = 4; // default to 'correct'
      });
    } else {
      setState(() {
        overrideQuality = 2; // 'again'
      });
    }
  }

  void _displayAnswer() {
    if (isEditing) {
      FocusScope.of(context).unfocus();
      _evaluateWrittenAnswer();
    }
    setState(() {
      isResponseHidden = false;
    });

  }

  @override
  Widget build(BuildContext context) {
    final isSubscribed = ref.watch(isSubscribedProvider);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = bottomInset > 0;

    // Si l'overlay est développé ET que le clavier est fermé,
    // on réserve un padding bottom égal à la hauteur mesurée de l'overlay.
    // Sinon on ne réserve rien (important pour ne pas "pousser" le layout quand le clavier s'ouvre).
    final extraBottomPadding = (isEditing && !isKeyboardOpen) ? _overlayHeight : 0.0;

    if(!isDue) {
      return const ReviewPageEmpty();
    }

    return Scaffold(
      resizeToAvoidBottomInset: false, // Empêche le push du layout quand le clavier s'ouvre
      body: Stack(
        // clipBehavior: Clip.none, // Permet à l'overlay de dépasser si nécessaire
        children: [
          SafeArea(
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              // On part de EdgeInsets.all(16) et on ajoute le padding bottom mesuré.
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + extraBottomPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  WordsDisplay(
                    questionLang: _questionLang,
                    questionText: _questionText,
                    responseLang: _responseLang,
                    responseText: _responseText,
                    isResponseHidden: isResponseHidden,
                    onDisplayAnswer: _displayAnswer,
                    isCardConsumed: isCardConsumed,
                  ),
                  const Spacer(),
                  ReviewControls(
                    isResponseHidden: isResponseHidden,
                    onQualityPress: (q) {
                      _onQualityButtonPress(q);
                    },
                    overrideDisplayWithResult:
                        isEditing && !isResponseHidden && overrideQuality != null,
                    overrideQuality: overrideQuality,
                  ),

                  const SizedBox(height: 32),
                  const Divider(),

                  if (isSubscribed)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AllLanguagesSwitch(
                          isAllLanguagesToggledNotifier:
                              widget.isAllLanguagesToggledNotifier,
                          onToggle: (newValue) {
                            updateSwitchState(newValue);
                            updateQuestionText(newValue);
                          },
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              isEditing = !isEditing;
                              if (!isEditing) {
                                overrideQuality = null;
                              }
                            });
                          },
                          icon: Icon(isEditing ? Icons.keyboard_arrow_down : Icons.edit),
                        ),
                      ],
                    ),
                  ],
              ),
            ),
          ),
          // Overlay pour EditAnswer
          if (isSubscribed)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedPadding(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              // Quand le clavier est ouvert, on pousse l'overlay au-dessus du clavier.
              // Quand il est fermé, padding bottom = 0 (on utilise l'espace réservé dans le body).
              padding: EdgeInsets.only(bottom: isKeyboardOpen ? bottomInset : 0),
              // On entoure l'overlay de MeasureSize pour obtenir sa hauteur.
              child: MeasureSize(
                onChange: (size) {
                  // Met à jour la hauteur uniquement si elle change (optimisation).
                  final newHeight = size.height;
                  if ((_overlayHeight - newHeight).abs() > 0.5) {
                    // seuil pour éviter setState à chaque pixel
                    if (mounted) {
                      setState(() {
                        _overlayHeight = newHeight;
                      });
                    }
                  }
                },
                child: EditAnswerOverlay(
                  isExpanded: isEditing,
                  controller: editingController,
                ),
              ),
              )
            ),
        ],
      ),
    );
  }
}
