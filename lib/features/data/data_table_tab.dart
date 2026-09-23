import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:flasholator/config/constants.dart';
import 'package:flasholator/core/providers/user_data_provider.dart';
import 'package:flasholator/core/providers/user_manager_provider.dart';
import 'package:flasholator/core/services/user_manager.dart';
import 'package:flasholator/features/data/data_providers.dart';
import 'package:flasholator/features/data/widgets/all_languages_table.dart';
import 'package:flasholator/features/data/widgets/couple_languages_table.dart';
import 'package:flasholator/features/data/widgets/edit_flashcard_popup.dart';
import 'package:flasholator/features/flashcards/application/flashcard_collection_projections.dart';
import 'package:flasholator/features/flashcards/domain/flashcard_pair.dart';
import 'package:flasholator/features/flashcards/domain/flashcard_pair_mutation_result.dart';
import 'package:flasholator/features/flashcards/flashcard_providers.dart';
import 'package:flasholator/features/shared/utils/app_localizations_helper.dart';
import 'package:flasholator/features/shared/utils/language_selection.dart';
import 'package:flasholator/features/shared/widgets/eraser_button.dart';
import 'package:flasholator/features/translation/translation_providers.dart';
import 'package:flasholator/l10n/app_localizations.dart';
import 'package:flasholator/style/grid_background_painter.dart';

class DataTableTab extends ConsumerStatefulWidget {
  const DataTableTab({super.key, required this.isAllLanguagesToggledNotifier});

  final ValueNotifier<bool> isAllLanguagesToggledNotifier;

  @override
  ConsumerState<DataTableTab> createState() => DataTableTabState();
}

class DataTableTabState extends ConsumerState<DataTableTab> {
  final LanguageSelection languageSelection = LanguageSelection.getInstance();

  void updateSwitchState(bool newValue) =>
      widget.isAllLanguagesToggledNotifier.value =
          newValue && ref.read(isSubscribedProvider);

  FlashcardPair _pairFromCard(FlashcardTablePair pair) => FlashcardPair(
        front: pair.card.front,
        back: pair.card.back,
        sourceLang: pair.card.sourceLang,
        targetLang: pair.card.targetLang,
      );

  FlashcardPair _pairFromValues(Map<String, String> values) => FlashcardPair(
        front: values['front']!.trim(),
        back: values['back']!.trim(),
        sourceLang: values['sourceLang']!.trim(),
        targetLang: values['targetLang']!.trim(),
      );

  Future<bool> _mutate(
      Future<FlashcardPairMutationResult?> Function() operation) async {
    final result = await operation();
    if (!mounted) return false;
    if (result == null) {
      Fluttertoast.showToast(
          msg: 'La modification n’a pas pu être enregistrée.');
      return false;
    }
    final message = switch (result) {
      FlashcardPairMutationResult.applied =>
        AppLocalizations.of(context)!.cardAdded,
      FlashcardPairMutationResult.notFound => 'Cette paire n’existe plus.',
      FlashcardPairMutationResult.conflict =>
        AppLocalizations.of(context)!.cardAlreadyAdded,
      FlashcardPairMutationResult.limitReached =>
        AppLocalizations.of(context)!.freeSubscriptionLimitsExceeded,
    };
    Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_SHORT);
    if (result == FlashcardPairMutationResult.limitReached) {
      _openSubscribePopup();
    }
    return result == FlashcardPairMutationResult.applied;
  }

  void _openEditFlashcardPopup(FlashcardTablePair pair) {
    final values = <String, String>{
      'front': pair.card.front,
      'back': pair.card.back,
      'sourceLang': pair.card.sourceLang,
      'targetLang': pair.card.targetLang,
    };
    showDialog<void>(
      context: context,
      builder: (_) => EditFlashcardPopup(
        row: values,
        languageDropdownEnabled: widget.isAllLanguagesToggledNotifier.value,
        isEditPopup: true,
        onEdit: (replacement) => _mutate(() => ref
            .read(dataTableViewModelProvider.notifier)
            .edit(
                source: _pairFromCard(pair),
                replacement: _pairFromValues(replacement))),
        onDelete: () => _mutate(() => ref
            .read(dataTableViewModelProvider.notifier)
            .delete(_pairFromCard(pair))),
      ),
    );
  }

  Future<void> _openSubscribePopup() async {
    try {
      final result = await ref.read(userManagerProvider).subscribeUser();
      if (mounted && result == SubscriptionActionResult.failed) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text(AppLocalizations.of(context)!.subscriptionCheckFailed)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text(AppLocalizations.of(context)!.subscriptionCheckFailed)));
      }
    }
  }

  Future<void> _checkIfCanAddCard() async {
    final canAddCard = await ref.read(flashcardAccessProvider).canAddCard();
    if (!mounted) return;
    if (ref.read(isSubscribedProvider) || canAddCard) {
      _openAddFlashcardPopup();
    } else {
      _openSubscribePopup();
    }
  }

  void _openAddFlashcardPopup() {
    showDialog<void>(
      context: context,
      builder: (_) => EditFlashcardPopup(
        row: {
          'front': '',
          'back': '',
          'sourceLang': languageSelection.sourceLanguage,
          'targetLang': languageSelection.targetLanguage,
        },
        languageDropdownEnabled: widget.isAllLanguagesToggledNotifier.value,
        isEditPopup: false,
        onAdd: (values) => _mutate(() => ref
            .read(dataTableViewModelProvider.notifier)
            .add(_pairFromValues(values))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languages = LANGUAGE_KEYS.map((code, key) => MapEntry(
        code, AppLocalizations.of(context)!.getTranslatedLanguageName(code)));
    final projection = ref.watch(flashcardTableProjectionProvider);
    final isSubscribed = ref.watch(isSubscribedProvider);
    return GridBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(children: [
          if (isSubscribed)
            Padding(
              padding: const EdgeInsets.all(8),
              child: ValueListenableBuilder<bool>(
                valueListenable: widget.isAllLanguagesToggledNotifier,
                builder: (_, value, __) => EraserButton(
                  onPressed: () => updateSwitchState(!value),
                  label: value
                      ? 'Afficher un seul couple de langues'
                      : 'Afficher tous les couples de langues',
                  gradientColors: value
                      ? [Colors.pink.shade300, Colors.pink.shade200]
                      : [Colors.blue.shade300, Colors.blue.shade200],
                  iconColor:
                      value ? Colors.pink.shade700 : Colors.blue.shade700,
                  textColor:
                      value ? Colors.pink.shade800 : Colors.blue.shade800,
                  isDisabled: false,
                ),
              ),
            ),
          Expanded(
            child: projection.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
              data: (table) => ValueListenableBuilder<bool>(
                valueListenable: widget.isAllLanguagesToggledNotifier,
                builder: (_, allLanguages, __) {
                  final showAll = isSubscribed && allLanguages;
                  final pairs = showAll
                      ? table.pairs
                      : table.pairs
                          .where((pair) =>
                              pair.card.sourceLang ==
                                  languageSelection.sourceLanguage &&
                              pair.card.targetLang ==
                                  languageSelection.targetLanguage)
                          .toList(growable: false);
                  return showAll
                      ? AllLanguagesTable(
                          data: pairs,
                          onCellTap: _openEditFlashcardPopup,
                          languages: languages)
                      : CoupleLanguagesTable(
                          data: pairs,
                          sourceLanguage:
                              languages[languageSelection.sourceLanguage]!,
                          targetLanguage:
                              languages[languageSelection.targetLanguage]!,
                          onCellTap: _openEditFlashcardPopup,
                        );
                },
              ),
            ),
          ),
          SizedBox(
            height: 50,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: EraserButton(
                onPressed: _checkIfCanAddCard,
                label: AppLocalizations.of(context)!.addAWord,
                gradientColors: [Colors.blue.shade300, Colors.blue.shade200],
                iconColor: Colors.white,
                textColor: Colors.white,
                isDisabled: false,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
