import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flasholator/config/constants.dart';
import 'package:flasholator/core/providers/user_data_provider.dart';
import 'package:flasholator/core/providers/user_manager_provider.dart';
import 'package:flasholator/core/services/deepl_translator.dart';
import 'package:flasholator/core/services/flashcards_service.dart';
import 'package:flasholator/features/shared/dialogs/cancel_dialog.dart';
import 'package:flasholator/features/shared/utils/app_localizations_helper.dart';
import 'package:flasholator/features/shared/utils/language_selection.dart';
import 'package:flasholator/features/shared/utils/lang_id_formater.dart';
import 'package:flasholator/features/translation/widgets/language_dropdown.dart';
import 'package:flasholator/l10n/app_localizations.dart';

import 'package:flasholator/features/translation/widgets/switch_lang_button.dart';
import 'package:flasholator/features/translation/widgets/bottom_block.dart';

class TranslateTab extends ConsumerStatefulWidget {
  final FlashcardsService flashcardsService;
  final DeeplTranslator deeplTranslator;
  final Function(Map<String, dynamic>) addRow;
  final Function() updateQuestionText;

  const TranslateTab({
    Key? key,
    required this.flashcardsService,
    required this.deeplTranslator,
    required this.addRow,
    required this.updateQuestionText,
  }) : super(key: key);

  @override
  ConsumerState<TranslateTab> createState() => _TranslateTabState();
}

class _TranslateTabState extends ConsumerState<TranslateTab> {
  final languageSelection = LanguageSelection();
  String? _lastCoupleLang;
  String _wordToTranslate = '';
  String _translatedWord = '';
  bool isTranslateButtonDisabled = true;
  bool isAddButtonDisabled = true;
  String _lastTranslatedWord = '';
  String _sourceLanguage = '';
  String _targetLanguage = '';
  late List<MapEntry<String, String>> sortedLanguageEntries;


  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateButtonState);

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

      sortedLanguageEntries = getSortedLanguageEntries(context, LANGUAGE_KEYS);;
  }

  @override
  void dispose() {
    _controller.removeListener(_updateButtonState);
    _controller.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    setState(() {
      isTranslateButtonDisabled =
          _controller.text.isEmpty || 
          _controller.text == _lastTranslatedWord;
    });
  }

  void _onLanguageChange(String newValue) {
    setState(() {
      _translatedWord = '';
      _lastTranslatedWord = '';
      isAddButtonDisabled = true;
      _updateButtonState();
    });
  }

  void _swapContent() {
    setState(() {
      final String tmp = languageSelection.sourceLanguage;
      languageSelection.sourceLanguage = languageSelection.targetLanguage;
      languageSelection.targetLanguage = tmp;
    });
  }

  void _openSubscribePopup() {
    final userManager = ref.read(userManagerProvider);
    userManager.subscribeUser();
  }

  void _checkIfCanTranslate() {
    final isSubscribed = ref.read(isSubscribedProvider);
    final canTranslate = ref.read(canTranslateProvider);

    if(isSubscribed || canTranslate) {
      _translate(isSubscribed);
    } else {
      _openSubscribePopup();
    }
  }

  Future<void> _translate(bool isSubscribed) async {
    isTranslateButtonDisabled = true;
    try {
      String translation = await widget.deeplTranslator.translate(
        _wordToTranslate,
        languageSelection.targetLanguage,
        languageSelection.sourceLanguage,
      );

      setState(() {
        _translatedWord = translation;
        _lastTranslatedWord = _wordToTranslate;
        _sourceLanguage = languageSelection.sourceLanguage;
        _targetLanguage = languageSelection.targetLanguage;
        isAddButtonDisabled = false;
        isTranslateButtonDisabled = true;
      });

      if(!isSubscribed) {
        final userManager = ref.read(userManagerProvider);
        await userManager.incrementCounter(context);
      }
    } catch (e) {
      print('Error translating text: $e');
    } finally {
      _updateButtonState();
    }
  }

  Future<void> _checkIfCanAddFlashcard() async {
    final isSubscribed = ref.read(isSubscribedProvider);
    final canAddCard = await widget.flashcardsService.canAddCard();
    if(isSubscribed || canAddCard) {
      _addFlashcard();
    } else {
      _openSubscribePopup();
    }
  }

  Future<void> _addFlashcard() async {
    if (_wordToTranslate != '' &&
        _translatedWord != '' &&
        _translatedWord != AppLocalizations.of(context)!.connectionError &&
        !await widget.flashcardsService
            .checkIfFlashcardExists(_wordToTranslate, _translatedWord)) {
      _wordToTranslate = _wordToTranslate.toLowerCase()[0].toUpperCase() +
          _wordToTranslate.toLowerCase().substring(1);
      _translatedWord = _translatedWord.toLowerCase()[0].toUpperCase() +
          _translatedWord.toLowerCase().substring(1);

      widget.addRow({
        'front': _wordToTranslate,
        'back': _translatedWord,
        'sourceLang': _sourceLanguage,
        'targetLang': _targetLanguage,
      });
      Future<bool> isCardAdded = widget.flashcardsService.addFlashcard(
          _wordToTranslate, _translatedWord, _sourceLanguage, _targetLanguage);

      widget.updateQuestionText();
      setState(() {
        isAddButtonDisabled = true;
      });

      // Confirm that the card was added
      Fluttertoast.showToast(
        msg: await isCardAdded
            ? AppLocalizations.of(context)!.cardAdded
            : AppLocalizations.of(context)!.cardAlreadyAdded,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }

    // open cancel dialog
    CancelDialog.show(
      context,
      onCancel: () {
        widget.flashcardsService
            .removeFlashcard(_wordToTranslate, _translatedWord);
        // close the dialog
        Navigator.of(context).pop();
        setState(() {
          isTranslateButtonDisabled = true;
          isAddButtonDisabled = false;
        });
        _updateButtonState();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSubscribed = ref.watch(isSubscribedProvider);

    final coupleLang = ref.watch(coupleLangProvider);

    if (coupleLang != _lastCoupleLang) {
      _lastCoupleLang = coupleLang;

      if (coupleLang.contains('-')) {
        languageSelection.sourceLanguage = coupleLang.split('-')[0];
        languageSelection.targetLanguage = coupleLang.split('-')[1];
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset:
          true, // ⚡ important : permet au bloc de remonter avec le clavier
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: 
                    LanguageDropdown(
                      selectedLanguage: languageSelection.sourceLanguage,
                      otherLanguage: languageSelection.targetLanguage,
                      sortedLanguages: sortedLanguageEntries.map((e) => MapEntry(e.key,
                    AppLocalizations.of(context)!.getTranslatedLanguageName(e.key)
                      )).toList(),
                      onChanged: isSubscribed
                      ? (val) {
                        setState(() {
                          languageSelection.sourceLanguage = val!;
                        });
                      }
                      : (val) {
                        _openSubscribePopup();
                      },
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: SwitchLangButton(
                      onPressed: () {
                              setState(() {
                                _swapContent();
                              });
                            },
                    ),
                  ),
                  Expanded(
                    child: LanguageDropdown(
                      selectedLanguage: languageSelection.targetLanguage,
                      otherLanguage: languageSelection.sourceLanguage,
                      sortedLanguages: sortedLanguageEntries.map((e) => MapEntry(e.key,
                        AppLocalizations.of(context)!.getTranslatedLanguageName(e.key)
                      )).toList(),
                      onChanged: isSubscribed
                      ? (val) {
                        setState(() {
                          languageSelection.targetLanguage = val!;
                        });
                      }: (val) {
                        _openSubscribePopup();
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            BottomBlock(
              controller: _controller,
              hintText: AppLocalizations.of(context)!.writeOrPasteYourTextHereForTranslation,
              translatedWord: _translatedWord,
              isTranslateButtonDisabled: isTranslateButtonDisabled,
              isAddButtonDisabled: isAddButtonDisabled,
              onClear: () {
                setState(() {
                  _controller.clear();
                  _wordToTranslate = '';
                  _translatedWord = '';
                  _lastTranslatedWord = '';
                  isTranslateButtonDisabled = true;
                  isAddButtonDisabled = true;
                });
                _updateButtonState();
              },
              onTranslate: _checkIfCanTranslate,
              onAdd: _checkIfCanAddFlashcard,
            ),
          ],
        ),
      ),
    );
  }
}
