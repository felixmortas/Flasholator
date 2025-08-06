import 'package:flutter/material.dart';
import 'package:flasholator/features/shared/utils/language_selection.dart';
import 'package:flasholator/features/shared/utils/app_localizations_helper.dart';
import 'package:flasholator/config/constants.dart';
import 'package:flasholator/l10n/app_localizations.dart';

class AddFlashcardPopup extends StatefulWidget {
  final Function(String front, String back) onAdd;

  const AddFlashcardPopup({super.key, required this.onAdd});

  @override
  State<AddFlashcardPopup> createState() => _AddFlashcardPopupState();
}

class _AddFlashcardPopupState extends State<AddFlashcardPopup> {
  String? front;
  String? back;
  late final Map<String, String> localizedLanguageMap;
  final LanguageSelection languageSelection = LanguageSelection.getInstance();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizedLanguageMap = LANGUAGE_KEYS.map(
      (code, key) => MapEntry(
        code,
        AppLocalizations.of(context)!.getTranslatedLanguageName(code),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.addAWord),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(localizedLanguageMap[languageSelection.sourceLanguage]!),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  onChanged: (value) => front = value,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(localizedLanguageMap[languageSelection.targetLanguage]!),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  onChanged: (value) => back = value,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: Navigator.of(context).pop,
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        TextButton(
          onPressed: () {
            if (front != null &&
                back != null &&
                front!.trim().isNotEmpty &&
                back!.trim().isNotEmpty) {
              widget.onAdd(front!.trim(), back!.trim());
              Navigator.of(context).pop();
            }
          },
          child: Text(AppLocalizations.of(context)!.add),
        ),
      ],
    );
  }
}
