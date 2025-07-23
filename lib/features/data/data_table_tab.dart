import '../../l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../core/services/flashcards_collection.dart';
import '../shared/utils/language_selection.dart';
import '../../config/constants.dart';
import '../shared/utils/app_localizations_helper.dart';
import 'widgets/all_languages_table.dart';
import 'widgets/couple_languages_table.dart';
import 'widgets/edit_flashcard_popup.dart';
import 'widgets/add_flashcard_popup.dart';

// Add doc comments
class DataTableTab extends StatefulWidget {
  final FlashcardsCollection flashcardsCollection;
  final Function() updateQuestionText;
  final ValueNotifier<bool> isAllLanguagesToggledNotifier;

  const DataTableTab({
    Key? key,
    required this.flashcardsCollection,
    required this.updateQuestionText,
    required this.isAllLanguagesToggledNotifier,
  }) : super(key: key);

  @override
  State<DataTableTab> createState() => DataTableTabState();
}

class DataTableTabState extends State<DataTableTab> {
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
    List<Map<dynamic, dynamic>> fetchedData =
        await widget.flashcardsCollection.loadData();
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

  void addRow(Map<dynamic, dynamic> row) {
    setState(() {
      data.add(row);
    });
  }

  void removeRow(Map<dynamic, dynamic> row) {
    widget.flashcardsCollection.removeFlashcard(row['front'], row['back']);
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
      widget.flashcardsCollection.editFlashcard(
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

  void _addFlashcard(String front, String back) {
    widget.flashcardsCollection.addFlashcard(front, back,
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

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
              onPressed: _openAddFlashcardPopup,
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
