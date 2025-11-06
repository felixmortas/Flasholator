import 'package:flasholator/features/shared/widgets/eraser_button.dart';
import 'package:flasholator/features/shared/widgets/paste_button.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

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
import 'package:flasholator/features/shared/widgets/bottom_overlay.dart';

import 'package:flasholator/style/grid_background_painter.dart';

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

      sortedLanguageEntries = getSortedLanguageEntries(context, LANGUAGE_KEYS);
  }

  @override
  void dispose() {
    _controller.removeListener(_updateButtonState);
    _controller.dispose();
    super.dispose();
  }

  void _clearTextInput() {
    setState(() {
      _controller.clear();
      _wordToTranslate = '';
      _translatedWord = '';
      _lastTranslatedWord = '';
      isTranslateButtonDisabled = true;
      isAddButtonDisabled = true;
    });
    _updateButtonState();
  }

  void _updateButtonState() {
    setState(() {
      isTranslateButtonDisabled =
          _controller.text.isEmpty || 
          _controller.text == _lastTranslatedWord;
    });
  }

  void _onLanguageChange(String? newValue, bool isSourceLanguage) {
    if(ref.read(isSubscribedProvider)) {
      setState(() {
        if (isSourceLanguage) {
          languageSelection.sourceLanguage = newValue!;
        } else {
          languageSelection.targetLanguage = newValue!;
        }
        _translatedWord = '';
        _lastTranslatedWord = '';
        isAddButtonDisabled = true;
        _updateButtonState();
      });

    } else {
      _openSubscribePopup();
    }
    
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
      _wordToTranslate = _controller.text.trim();
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
    final coupleLang = ref.watch(coupleLangProvider);

    if (coupleLang != _lastCoupleLang) {
      _lastCoupleLang = coupleLang;

      if (coupleLang.contains('-')) {
        languageSelection.sourceLanguage = coupleLang.split('-')[0];
        languageSelection.targetLanguage = coupleLang.split('-')[1];
      }
    }

    return GridBackground(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.transparent, 
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
                        onChanged: (String? newValue) {
                          _onLanguageChange(newValue, true);
                        },
                      ),
                    ),
                                      
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: SwitchLangButton(
                        onPressed: _swapContent,
                      ),
                    ),
                    Expanded(
                      child: LanguageDropdown(
                        selectedLanguage: languageSelection.targetLanguage,
                        otherLanguage: languageSelection.sourceLanguage,
                        sortedLanguages: sortedLanguageEntries.map((e) => MapEntry(e.key,
                          AppLocalizations.of(context)!.getTranslatedLanguageName(e.key)
                        )).toList(),
                        onChanged: (String? newValue) {
                          _onLanguageChange(newValue, false);
                        },
                      ),
                    ),
                  ],
                ),
              ),
      
              const Spacer(),
              AnimatedPadding(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: BottomBlock(
                  showDragHandle: true,
                  children: [
                    _InputFieldWithClear(
                      controller: _controller,
                      onClear: _clearTextInput
                    ),
                    _PasteAndCameraRow(controller: _controller),
                    const Divider(),
                    const SizedBox(height: 12),
                    _TranslatedText(
                      translatedWord: _translatedWord,
                      onVolumePressed: () {},
                      onAlternativePressed: () {},
                      onSharePressed: () {
                        if (_translatedWord.isNotEmpty) {
                          Share.share(
                            'Grâce à Flasholator, je vais pouvoir retenir éternellement ce mot que je viens de traduire : $_translatedWord\n\n'
                            '📱 Toi aussi télécharge Flasholator pour avoir une mémoire d\'éléphant !',
                            subject: 'Apprendre avec Flasholator',
                          );
                        }

                      },
                    ),
                    const SizedBox(height: 16),
                    _ActionButtons(
                      isTranslateDisabled: isTranslateButtonDisabled,
                      isAddDisabled: isAddButtonDisabled,
                      onTranslate: _checkIfCanTranslate,
                      onAdd: _checkIfCanAddFlashcard,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );  
  }
}

class _InputFieldWithClear extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onClear;

  const _InputFieldWithClear({
    required this.controller,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        TextField(
          key: const Key('input_textfield'),
          controller: controller,
          maxLength: 100,
          style: const TextStyle(fontSize: 24.0),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: AppLocalizations.of(context)!
                .writeOrPasteYourTextHereForTranslation,
            hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
            counterText: "",
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
        IconButton(
          key: const Key('clear_input_button'),
          onPressed: onClear,
          icon: const Icon(Icons.clear),
        ),
      ],
    );
  }
}

class _PasteAndCameraRow extends StatelessWidget {
  final TextEditingController controller;

  const _PasteAndCameraRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          PasteButton(controller: controller),
          // IconButton(
          //   onPressed: () {
          //     // TODO: action caméra
          //   },
          //   icon: const Icon(Icons.camera_alt),
          // ),
        ],
      ),
    );
  }
}

class _TranslatedText extends StatelessWidget {
  final String translatedWord;
  final VoidCallback onVolumePressed;
  final VoidCallback onAlternativePressed;
  final VoidCallback onSharePressed;

  const _TranslatedText({
    required this.translatedWord,
    required this.onVolumePressed,
    required this.onAlternativePressed,
    required this.onSharePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          translatedWord,
          style: const TextStyle(fontSize: 24.0),
        ),
        if (translatedWord.isNotEmpty)
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // IconButton(
                //   onPressed: onVolumePressed,
                //   icon: const Icon(Icons.volume_up),
                //   iconSize: 18,
                //   padding: EdgeInsets.zero,
                //   constraints: const BoxConstraints(),
                // ),
                // OutlinedButton(
                //   onPressed: onAlternativePressed,
                //   style: OutlinedButton.styleFrom(
                //     side: const BorderSide(width: 1.0, color: Colors.black),
                //     padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                //     minimumSize: Size.zero,
                //     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                //   ),
                //   child: const Text("ALTERNATIVE", style: TextStyle(fontSize: 12)),
                // ),
                IconButton(
                  onPressed: onSharePressed,
                  icon: const Icon(Icons.share),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final bool isTranslateDisabled;
  final bool isAddDisabled;
  final VoidCallback onTranslate;
  final VoidCallback onAdd;

  const _ActionButtons({
    required this.isTranslateDisabled,
    required this.isAddDisabled,
    required this.onTranslate,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: EraserButton(
            onPressed: isTranslateDisabled ? null : onTranslate,
            label: AppLocalizations.of(context)!.translate,
            gradientColors: [
              Colors.pink.shade200,
              Colors.pink.shade100,
            ],
            iconColor: Colors.pink.shade700,
            textColor: Colors.pink.shade900,
            isDisabled: isTranslateDisabled,
          ),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: EraserButton(
            onPressed: isAddDisabled ? null : onAdd,
            label: AppLocalizations.of(context)!.add,
            gradientColors: [
              Colors.blue.shade200,
              Colors.blue.shade100,
            ],
            iconColor: Colors.blue.shade700,
            textColor: Colors.blue.shade900,
            isDisabled: isAddDisabled,
          ),
        ),
      ],
    );
  }
}

