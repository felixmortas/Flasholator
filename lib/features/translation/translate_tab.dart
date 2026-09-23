import 'package:flasholator/features/shared/widgets/eraser_button.dart';
import 'package:flasholator/features/shared/widgets/paste_button.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'package:flasholator/config/constants.dart';
import 'package:flasholator/core/providers/user_data_provider.dart';
import 'package:flasholator/core/providers/user_manager_provider.dart';
import 'package:flasholator/core/services/user_manager.dart';
import 'package:flasholator/core/presentation/ui_phase.dart';
import 'package:flasholator/features/shared/utils/app_localizations_helper.dart';
import 'package:flasholator/features/shared/utils/language_selection.dart';
import 'package:flasholator/features/shared/utils/lang_id_formater.dart';
import 'package:flasholator/features/translation/widgets/language_dropdown.dart';
import 'package:flasholator/features/translation/translation_providers.dart';
import 'package:flasholator/l10n/app_localizations.dart';

import 'package:flasholator/features/translation/widgets/switch_lang_button.dart';
import 'package:flasholator/features/shared/widgets/bottom_overlay.dart';

import 'package:flasholator/style/grid_background_painter.dart';

class TranslateTab extends ConsumerStatefulWidget {
  const TranslateTab({super.key});

  @override
  ConsumerState<TranslateTab> createState() => _TranslateTabState();
}

class _TranslateTabState extends ConsumerState<TranslateTab> {
  final languageSelection = LanguageSelection();
  String? _lastCoupleLang;
  String _wordToTranslate = '';
  bool isTranslateButtonDisabled = true;
  bool isAddButtonDisabled = true;
  String _lastTranslatedWord = '';
  String _sourceLanguage = '';
  String _targetLanguage = '';
  late List<MapEntry<String, String>> sortedLanguageEntries;
  late final ProviderSubscription<String> _coupleLangSubscription;

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateButtonState);
    _lastCoupleLang = ref.read(coupleLangProvider);
    _applyCoupleLanguage(_lastCoupleLang!, invalidate: false);
    _coupleLangSubscription = ref.listenManual<String>(
      coupleLangProvider,
      (previous, next) {
        if (previous != next) _applyCoupleLanguage(next);
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    sortedLanguageEntries = getSortedLanguageEntries(context, languageKeys);
  }

  @override
  void dispose() {
    _controller.removeListener(_updateButtonState);
    _controller.dispose();
    _coupleLangSubscription.close();
    super.dispose();
  }

  void _clearTextInput() {
    _invalidateTranslationRequests();
    _controller.clear();
    setState(() {
      _wordToTranslate = '';
      _lastTranslatedWord = '';
      isTranslateButtonDisabled = true;
      isAddButtonDisabled = true;
    });
  }

  void _updateButtonState() {
    ref.read(translationViewModelProvider.notifier).invalidate();
    setState(() {
      isTranslateButtonDisabled =
          _controller.text.isEmpty || _controller.text == _lastTranslatedWord;
    });
  }

  void _invalidateTranslationRequests() {
    ref.read(translationViewModelProvider.notifier).invalidate();
  }

  void _applyCoupleLanguage(String coupleLang, {bool invalidate = true}) {
    if (invalidate) _invalidateTranslationRequests();
    _lastCoupleLang = coupleLang;
    if (coupleLang.contains('-')) {
      final languages = coupleLang.split('-');
      languageSelection.sourceLanguage = languages[0];
      languageSelection.targetLanguage = languages[1];
    } else {
      languageSelection.reset();
    }
    if (!mounted) return;
    setState(() {
      _lastTranslatedWord = '';
      isAddButtonDisabled = true;
      isTranslateButtonDisabled = _controller.text.trim().isEmpty;
    });
  }

  Future<void> _onLanguageChange(String? newValue, bool isSourceLanguage) async {
    if (newValue == null) return;
    final session = ref.read(translationSessionContextProvider);
    final source = isSourceLanguage ? newValue : languageSelection.sourceLanguage;
    final target = isSourceLanguage ? languageSelection.targetLanguage : newValue;
    final allowed = await ref.read(userManagerProvider)
        .tryUseLanguagePair(source, target,
          isCurrent: () => mounted &&
              ref.read(translationSessionContextProvider) == session);
    if (!mounted || ref.read(translationSessionContextProvider) != session) {
      return;
    }
    if (allowed) {
      _invalidateTranslationRequests();
      setState(() {
        if (isSourceLanguage) {
          languageSelection.sourceLanguage = newValue;
        } else {
          languageSelection.targetLanguage = newValue;
        }
        _lastTranslatedWord = '';
        isAddButtonDisabled = true;
        isTranslateButtonDisabled = _controller.text.trim().isEmpty;
      });
    } else {
      _openSubscribePopup();
    }
  }

  void _swapContent() {
    _invalidateTranslationRequests();
    setState(() {
      final String tmp = languageSelection.sourceLanguage;
      languageSelection.sourceLanguage = languageSelection.targetLanguage;
      languageSelection.targetLanguage = tmp;
      _lastTranslatedWord = '';
      isAddButtonDisabled = true;
      isTranslateButtonDisabled = _controller.text.trim().isEmpty;
    });
  }

  Future<void> _openSubscribePopup() async {
    try {
      final result = await ref.read(userManagerProvider).subscribeUser();
      if (mounted && result == SubscriptionActionResult.failed) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)!.subscriptionCheckFailed)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)!.subscriptionCheckFailed)));
      }
    }
  }

  void _checkIfCanTranslate() {
    final isSubscribed = ref.read(isSubscribedProvider);
    final canTranslate = ref.read(canTranslateProvider);

    if (isSubscribed || canTranslate) {
      _translate(isSubscribed);
    } else {
      _openSubscribePopup();
    }
  }

  Future<void> _translate(bool isSubscribed) async {
    final requestedText = _controller.text.trim();
    final sourceLanguage = languageSelection.sourceLanguage;
    final targetLanguage = languageSelection.targetLanguage;
    _wordToTranslate = requestedText;
    setState(() => isTranslateButtonDisabled = true);
    final session = ref.read(translationSessionContextProvider);
    final result = await ref.read(translationViewModelProvider.notifier).translate(
          text: requestedText,
          sourceLanguage: sourceLanguage,
          targetLanguage: targetLanguage,
        );
    if (!mounted ||
        result == null ||
        ref.read(translationSessionContextProvider) != session ||
        !identical(ref.read(translationViewModelProvider).result, result) ||
        _controller.text.trim() != requestedText ||
        languageSelection.sourceLanguage != sourceLanguage ||
        languageSelection.targetLanguage != targetLanguage ||
        result.sourceLanguage != sourceLanguage ||
        result.targetLanguage != targetLanguage) {
      if (mounted &&
          ref.read(translationViewModelProvider).phase != UiPhase.loading &&
          _controller.text.trim() == requestedText &&
          languageSelection.sourceLanguage == sourceLanguage &&
          languageSelection.targetLanguage == targetLanguage) {
        setState(() {
          isTranslateButtonDisabled = _controller.text.isEmpty ||
              _controller.text == _lastTranslatedWord;
        });
      }
      return;
    }
    setState(() {
      _lastTranslatedWord = _wordToTranslate;
      _sourceLanguage = result.sourceLanguage;
      _targetLanguage = result.targetLanguage;
      isAddButtonDisabled = false;
      isTranslateButtonDisabled = true;
    });
    if (!isSubscribed && mounted) {
      await ref.read(userManagerProvider).incrementCounter(
        isCurrent: () => mounted &&
            ref.read(translationSessionContextProvider) == session &&
            identical(ref.read(translationViewModelProvider).result, result),
      );
    }
  }

  Future<void> _checkIfCanAddFlashcard() async {
    final isSubscribed = ref.read(isSubscribedProvider);
    final canAddCard = await ref.read(flashcardAccessProvider).canAddCard();
    if (!mounted) return;
    if (isSubscribed || canAddCard) {
      _addFlashcard();
    } else {
      _openSubscribePopup();
    }
  }

  Future<void> _addFlashcard() async {
    final result = ref.read(translationViewModelProvider).result;
    final sourceLanguage = _sourceLanguage;
    final targetLanguage = _targetLanguage;
    if (result == null) return;
    final mutation = await ref.read(translationSaveViewModelProvider.notifier).save(
      result: result,
      isCurrent: () => mounted &&
          identical(ref.read(translationViewModelProvider).result, result) &&
          _wordToTranslate == result.sourceText &&
          _sourceLanguage == sourceLanguage &&
          _targetLanguage == targetLanguage,
    );
    if (!mounted || mutation == null) {
      if (mounted &&
          ref.read(translationSaveViewModelProvider).error != null) {
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.connectionError,
          toastLength: Toast.LENGTH_SHORT,
        );
      }
      return;
    }
    if (mutation.name == 'limitReached') {
      _openSubscribePopup();
      return;
    }
    if (mutation.name == 'applied') setState(() => isAddButtonDisabled = true);
    Fluttertoast.showToast(
        msg: mutation.name == 'applied'
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

  @override
  Widget build(BuildContext context) {
    final translationState = ref.watch(translationViewModelProvider);

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
                      child: LanguageDropdown(
                        selectedLanguage: languageSelection.sourceLanguage,
                        otherLanguage: languageSelection.targetLanguage,
                        sortedLanguages: sortedLanguageEntries
                            .map((e) => MapEntry(
                                e.key,
                                AppLocalizations.of(context)!
                                    .getTranslatedLanguageName(e.key)))
                            .toList(),
                        onChanged: (String? newValue) {
                          _onLanguageChange(newValue, true);
                        },
                      ),
                    ),
                    SwitchLangButton(
                      onPressed: _swapContent,
                    ),
                    Expanded(
                      child: LanguageDropdown(
                        selectedLanguage: languageSelection.targetLanguage,
                        otherLanguage: languageSelection.sourceLanguage,
                        sortedLanguages: sortedLanguageEntries
                            .map((e) => MapEntry(
                                e.key,
                                AppLocalizations.of(context)!
                                    .getTranslatedLanguageName(e.key)))
                            .toList(),
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
                        controller: _controller, onClear: _clearTextInput),
                    _PasteAndCameraRow(controller: _controller),
                    const Divider(),
                    const SizedBox(height: 12),
                    _TranslatedText(
                      translatedWord: translationState.result?.text ??
                          (translationState.phase == UiPhase.error
                              ? AppLocalizations.of(context)!.connectionError
                              : ''),
                      onVolumePressed: () {},
                      onAlternativePressed: () {},
                      onSharePressed: () {
                        final translatedWord = translationState.result?.text ?? '';
                        if (translatedWord.isNotEmpty) {
                          Share.share(
                            'Grâce à Flasholator, je vais pouvoir retenir éternellement ce mot que je viens de traduire : $translatedWord\n\n'
                            '📱 Toi aussi télécharge Flasholator pour avoir une mémoire d\'éléphant !',
                            subject: 'Apprendre avec Flasholator',
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    _ActionButtons(
                      isTranslateDisabled: isTranslateButtonDisabled,
                      isAddDisabled: isAddButtonDisabled ||
                          translationState.phase != UiPhase.data,
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
            hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.5)),
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
