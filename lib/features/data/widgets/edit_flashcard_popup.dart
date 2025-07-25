import '../../../l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../../../config/constants.dart';

class EditFlashcardPopup extends StatefulWidget {
  final Map<dynamic, dynamic> row;
  final Function(Map<String, String>, Map<dynamic, dynamic>) onEdit;
  final Function(Map<dynamic, dynamic>) onDelete;
  final bool languageDropdownEnabled;

  EditFlashcardPopup({
    required this.row,
    required this.onEdit,
    required this.onDelete,
    required this.languageDropdownEnabled,
  });

  @override
  _EditFlashcardPopupState createState() => _EditFlashcardPopupState();
}

class _EditFlashcardPopupState extends State<EditFlashcardPopup> {
  late String _sourceLanguage;
  late String _word;
  late String _translation;
  late String _targetLanguage;

  @override
  void initState() {
    super.initState();
    _sourceLanguage = widget.row['sourceLang'];
    _word = widget.row['front'];
    _translation = widget.row['back'];
    _targetLanguage = widget.row['targetLang'];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.editTheRow),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildInputRow(
            _sourceLanguage,
            (value) => _sourceLanguage = value!,
            _word,
            (value) => _word = value,
            widget.languageDropdownEnabled,
          ),
          _buildInputRow(
            _targetLanguage,
            (value) => _targetLanguage = value!,
            _translation,
            (value) => _translation = value,
            widget.languageDropdownEnabled,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onDelete(widget.row);
            Navigator.of(context).pop();
          },
          child: Text(AppLocalizations.of(context)!.remove),
        ),
        TextButton(
          onPressed: () {
            widget.onEdit({
              'sourceLang': _sourceLanguage,
              'front': _word,
              'back': _translation,
              'targetLang': _targetLanguage,
            }, widget.row);
            Navigator.of(context).pop();
          },
          child: const Text('Modifier'),
        ),
      ],
    );
  }

  Widget _buildInputRow(
    String languageValue,
    Function(String?) onLanguageChanged,
    String textValue,
    Function(String) onTextChanged,
    bool languageDropdownEnabled,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const SizedBox(width: 8.0),
          Flexible(
            flex: 2,
            child: DropdownButton<String>(
              isExpanded: true,
              value: languageValue,
              onChanged: languageDropdownEnabled
                  ? (String? newValue) {
                      if (newValue != null) {
                        onLanguageChanged(newValue);
                        setState(() {
                          languageValue = newValue;
                        });
                      }
                    }
                  : null,
              items: LANGUAGE_KEYS.keys.map((String key) {
                return DropdownMenuItem<String>(
                  value: key,
                  child: Text(LANGUAGE_KEYS[key]!),
                );
              }).toList(),
            ),
          ),
          const SizedBox(width: 8.0),
          Flexible(
            flex: 3,
            child: TextField(
              controller: TextEditingController(text: textValue),
              onChanged: onTextChanged,
            ),
          ),
        ],
      ),
    );
  }
}
