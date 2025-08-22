import 'package:flasholator/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flasholator/config/constants.dart';

class EditFlashcardPopup extends StatefulWidget {
  final Map<dynamic, dynamic> row;
  final bool languageDropdownEnabled;
  final bool isEditPopup;
  final Function(Map<String, String>, Map<dynamic, dynamic>)? onEdit;
  final Function(Map<dynamic, dynamic>)? onDelete;
  final Function(Map<String, dynamic>)? onAdd;

  EditFlashcardPopup({
    required this.row,
    required this.languageDropdownEnabled,
    required this.isEditPopup,
    this.onEdit,
    this.onDelete,
    this.onAdd,
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

  void _setConfirmButton(String text) {
    if(text=='edit') {
      widget.onEdit!({
        'sourceLang': _sourceLanguage,
        'front': _word,
        'back': _translation,
        'targetLang': _targetLanguage,
      }, widget.row);
    } else if(text=='delete') {
      widget.onDelete!(widget.row);
    } else if(text=='add') {
      widget.onAdd!({
        'sourceLang': _sourceLanguage,
        'front': _word,
        'back': _translation,
        'targetLang': _targetLanguage,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEditPopup ? AppLocalizations.of(context)!.editTheRow : 'Ajouter une nouvelle carte'),
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
            _setConfirmButton(widget.isEditPopup ? 'delete' : 'cancel');
            Navigator.of(context).pop();
          },
          child: Text(widget.isEditPopup ? AppLocalizations.of(context)!.remove : 'Annuler'),
        ),
        TextButton(
          onPressed: () {
            _setConfirmButton(widget.isEditPopup ? 'edit' : 'add');
            Navigator.of(context).pop();
          },
          child: Text(widget.isEditPopup ? 'Modifier' : 'Ajouter'),
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
