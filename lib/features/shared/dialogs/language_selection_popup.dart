// widgets/language_selection_popup.dart
import 'package:flasholator/features/shared/utils/lang_id_formater.dart';
import 'package:flasholator/features/shared/widgets/language_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flasholator/config/constants.dart';
import 'package:flasholator/features/shared/utils/language_selection.dart';
import 'package:flasholator/l10n/app_localizations.dart';

class LanguageSelectionPopup extends StatefulWidget {
  final Future<void> Function(String sourceLang, String targetLang) onSave;

  const LanguageSelectionPopup({
    super.key,
    required this.onSave,
  });

  @override
  State<LanguageSelectionPopup> createState() => _LanguageSelectionPopupState();
}

class _LanguageSelectionPopupState extends State<LanguageSelectionPopup> {
  late List<MapEntry<String, String>> sortedLanguageEntries;
  final languageSelection = LanguageSelection();

  String? selectedSource;
  String? selectedTarget;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sortedLanguageEntries = getSortedLanguageEntries(
      context,
      LANGUAGE_KEYS,
    );
    selectedSource = languageSelection.sourceLanguage;
    selectedTarget = languageSelection.targetLanguage;
  }

  bool get isValidSelection =>
      selectedSource != null &&
      selectedTarget != null &&
      selectedSource != selectedTarget;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.chooseYourLanguagePair),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LanguageDropdown(
            label: AppLocalizations.of(context)!.sourceLanguage,
            selectedLanguage: selectedSource!,
            otherLanguage: selectedTarget!,
            sortedLanguages: sortedLanguageEntries,
            onChanged: (val) => setState(() => selectedSource = val),
          ),
          const SizedBox(height: 12),
          LanguageDropdown(
            label: AppLocalizations.of(context)!.targetLanguage,
            selectedLanguage: selectedTarget!,
            otherLanguage: selectedSource!,
            sortedLanguages: sortedLanguageEntries,
            onChanged: (val) => setState(() => selectedTarget = val),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.subscriptionWarningForLanguageChange,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: isValidSelection
              ? () async {
                  await widget.onSave(selectedSource!, selectedTarget!);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              : null,
          child: Text(AppLocalizations.of(context)!.continueAction),
        ),
      ],
    );
  }
}