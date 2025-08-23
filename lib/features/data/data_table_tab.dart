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
    _fetchData(newValue);
  }

  Future<void> _fetchData(bool isAllLanguagesToggled) async {
    final flashcards = await widget.flashcardsService.loadAllFlashcards();
    final fetchedData = flashcards.map((f) => f.toMap()).toList();

    List<Map<dynamic, dynamic>> newData;

    if (isAllLanguagesToggled) {
      newData = fetchedData
          .where((row) => fetchedData.indexOf(row) % 2 == 0)
          .toList();
    } else {
      newData = fetchedData
          .where((row) =>
              row['sourceLang'] == languageSelection.sourceLanguage &&
              row['targetLang'] == languageSelection.targetLanguage)
          .toList();
    }

    setState(() {
      data = newData;
      widget.isAllLanguagesToggledNotifier.value = isAllLanguagesToggled;
    });
  }

  void addRow(Map<String, dynamic> row) {
    print("enter add row in data table");
    final front = row['front'];
    final back = row['back'];
    final sourceLanguage = row['sourceLang'];
    final targetLanguage = row['targetLang'];

    if (!data.contains(row)) {
      print("Adding row to db: $row");
      widget.flashcardsService.addFlashcard(front, back, sourceLanguage, targetLanguage);
      setState(() {
        print("add row to table");
        data.add(row);
        print("row added to db and table !");
      });
      widget.updateQuestionText();
    }
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
          isEditPopup: true,
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

  void _openAddFlashcardPopup() {
    Map<dynamic, dynamic> newRowData = {
      'front': '',
      'back': '',
      'sourceLang': languageSelection.sourceLanguage,
      'targetLang': languageSelection.targetLanguage
    };
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditFlashcardPopup(
          row: newRowData,
          languageDropdownEnabled: widget.isAllLanguagesToggledNotifier.value,
          isEditPopup: false,
          onAdd: (Map<String, dynamic> row) {
            addRow(row);
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
                  return SwitchListTile(
                    value: value, // ref.watch(notificationsProvider),
                    onChanged: (bool newValue) {
                      updateSwitchState(newValue);
                    },
                    title: const Text("Sélectionner toutes les langues"),
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
