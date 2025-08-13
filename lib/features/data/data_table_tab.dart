import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flasholator/l10n/app_localizations.dart';
import 'package:flasholator/core/providers/user_data_provider.dart';
import 'package:flasholator/core/providers/user_manager_provider.dart';
import 'package:flasholator/core/services/flashcards_service.dart';
import 'package:flasholator/config/constants.dart';
import 'package:flasholator/features/data/widgets/all_languages_table.dart';
import 'package:flasholator/features/data/widgets/couple_languages_table.dart';
import 'package:flasholator/features/data/widgets/edit_flashcard_popup.dart';
import 'package:flasholator/features/data/widgets/add_flashcard_popup.dart';
import 'package:flasholator/features/shared/utils/app_localizations_helper.dart';
import 'package:flasholator/features/shared/utils/language_selection.dart';

// Add doc comments
class DataTableTab extends ConsumerStatefulWidget {
  final FlashcardsService flashcardsService;
  final Function() updateQuestionText;
  final ValueNotifier<bool> isAllLanguagesToggledNotifier;

  const DataTableTab({
    Key? key,
    required this.flashcardsService,
    required this.updateQuestionText,
    required this.isAllLanguagesToggledNotifier,
  }) : super(key: key);

  @override
  ConsumerState<DataTableTab> createState() => DataTableTabState();
}

class DataTableTabState extends ConsumerState<DataTableTab> {
  List<Map<dynamic, dynamic>> data = [];
  LanguageSelection languageSelection = LanguageSelection.getInstance();

  @override
  void initState() {
    super.initState();
    _fetchData(widget.isAllLanguagesToggledNotifier.value);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void updateSwitchState(bool newValue) {
    setState(() {
      widget.isAllLanguagesToggledNotifier.value = newValue;
    });
  }

  Future<void> _fetchData(bool isAllLanguagesToggled) async {
    final flashcards = await widget.flashcardsService.loadAllFlashcards();
    
    // On convertit chaque Flashcard en Map<String, dynamic>
    final fetchedData = flashcards.map((f) => f.toMap()).toList();

    setState(() {
      if (isAllLanguagesToggled) {
        data = fetchedData
            .where((row) => fetchedData.indexOf(row) % 2 == 0)
            .toList();
      } else {
        data = fetchedData
            .where((row) =>
                row['sourceLang'] == languageSelection.sourceLanguage &&
                row['targetLang'] == languageSelection.targetLanguage)
            .toList();
      }
    });
  }

  void addRow(Map<String, dynamic> row) {
    setState(() {
      data.add(row);
    });
  }

  void removeRow(Map<dynamic, dynamic> row) {
    widget.flashcardsService.removeFlashcard(row['front'], row['back']);
    setState(() {
      data.removeAt(data.indexOf(row));
    });
  }

  void editRow(Map<String, String> newData, Map<dynamic, dynamic> row) {
    final front = row['front'];
    final back = row['back'];
    final sourceLanguage = row['sourceLang'];
    final targetLanguage = row['targetLang'];

    if (data.contains(row)) {
      widget.flashcardsService.editFlashcard(
          front,
          back,
          sourceLanguage,
          targetLanguage,
          newData['front']!,
          newData['back']!,
          newData['sourceLang']!,
          newData['targetLang']!);
      setState(() {
        row['sourceLang'] = newData['sourceLang'];
        row['front'] = newData['front'];
        row['back'] = newData['back'];
        row['targetLang'] = newData['targetLang'];
      });
      widget.updateQuestionText();
    }
  }

  void _openEditFlashcardPopup(Map<dynamic, dynamic> row) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditFlashcardPopup(
          row: row,
          onEdit: editRow,
          onDelete: removeRow,
          languageDropdownEnabled: widget.isAllLanguagesToggledNotifier.value,
        );
      },
    );
  }

  void _openSubscribePopup() {
    final userManager = ref.read(userManagerProvider);
    userManager.subscribeUser();
  }

  Future<void> _checkIfCanAddCard() async {
    final isSubscribed = ref.read(isSubscribedProvider);
    final canAddCard = await widget.flashcardsService.canAddCard();

    if (isSubscribed || canAddCard) {
      _openAddFlashcardPopup();
    } else {
      _openSubscribePopup();
    }
  }

  void _addFlashcard(String front, String back) {
    widget.flashcardsService.addFlashcard(front, back,
          languageSelection.sourceLanguage, languageSelection.targetLanguage);
    addRow({'front': front, 'back': back});
  }

  void _openAddFlashcardPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddFlashcardPopup(
          onAdd: (String front, String back) {
            _addFlashcard(front, back);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizedLanguageMap = LANGUAGE_KEYS.map(
      (code, key) => MapEntry(
          code, AppLocalizations.of(context)!.getTranslatedLanguageName(code)),
    );
    final isSubscribed = ref.watch(isSubscribedProvider);

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isSubscribed)
              ValueListenableBuilder<bool>(
                valueListenable: widget.isAllLanguagesToggledNotifier,
                builder: (context, value, child) {
                  return Switch(
                    value: value,
                    onChanged: (bool newValue) {
                      widget.isAllLanguagesToggledNotifier.value = newValue;
                      _fetchData(newValue);
                    },
                  );
                },
              ),
            Expanded(
              child: ValueListenableBuilder<bool>(
                valueListenable: widget.isAllLanguagesToggledNotifier,
                builder: (context, isAllLanguagesToggled, child) {
                  if (isAllLanguagesToggled) {
                    return AllLanguagesTable(
                      data: data,
                      onCellTap:
                          _openEditFlashcardPopup, // Modified to pass only rowData
                      languages: localizedLanguageMap,
                    );
                  } else {
                    return CoupleLanguagesTable(
                      data: data,
                      sourceLanguage: localizedLanguageMap[
                          languageSelection.sourceLanguage]!,
                      targetLanguage: localizedLanguageMap[
                          languageSelection.targetLanguage]!,

                      onCellTap:
                          _openEditFlashcardPopup, // Modified to pass only rowData
                    );
                  }
                },
              ),
            ),
            ElevatedButton(
              onPressed: _checkIfCanAddCard,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(AppLocalizations.of(context)!.addAWord),
            ),
          ],
        ),
      );
    });
  }
}
