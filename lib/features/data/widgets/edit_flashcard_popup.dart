import 'package:flasholator/features/shared/utils/app_localizations_helper.dart';
import 'package:flasholator/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flasholator/config/constants.dart';
import 'package:google_fonts/google_fonts.dart';

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
  late String _targetLanguage;

  late TextEditingController _wordController;
  late TextEditingController _translationController;

  @override
  void initState() {
    super.initState();
    _sourceLanguage = widget.row['sourceLang'];
    _targetLanguage = widget.row['targetLang'];

    // Initialize controllers with initial values
    _wordController = TextEditingController(text: widget.row['front']);
    _translationController = TextEditingController(text: widget.row['back']);
  }

  @override
  void dispose() {
    // Always dispose controllers to prevent memory leaks
    _wordController.dispose();
    _translationController.dispose();
    super.dispose();
  }

  void _setConfirmButton(String text) {
    if (text == 'edit') {
      widget.onEdit!({
        'sourceLang': _sourceLanguage,
        'front': _wordController.text,
        'back': _translationController.text,
        'targetLang': _targetLanguage,
      }, widget.row);
    } else if (text == 'delete') {
      widget.onDelete!(widget.row);
    } else if (text == 'add') {
      widget.onAdd!({
        'sourceLang': _sourceLanguage,
        'front': _wordController.text,
        'back': _translationController.text,
        'targetLang': _targetLanguage,
      });
    }
  }

  Color _getDarkerShade(Color color, double opacity) {
    final hsl = HSLColor.fromColor(color);
    final darkened = hsl.withLightness((hsl.lightness - 0.15).clamp(0.0, 1.0));
    return darkened.toColor().withOpacity(opacity);
  }

  @override
  Widget build(BuildContext context) {
    final postItColor = Colors.yellow.shade100;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(-0.01)
          ..rotateZ(-0.02),
        alignment: Alignment.center,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 450,
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          decoration: BoxDecoration(
            color: postItColor,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 2,
                offset: const Offset(0, 1),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(3, 4),
                spreadRadius: -1,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bande adhésive en haut
              Container(
                height: 16,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _getDarkerShade(postItColor, 0.4),
                      _getDarkerShade(postItColor, 0.25),
                      _getDarkerShade(postItColor, 0.1),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _getDarkerShade(postItColor, 0.15),
                      blurRadius: 1,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
              // Contenu du post-it
              Flexible(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Titre
                        Text(
                          widget.isEditPopup
                              ? AppLocalizations.of(context)!.editTheRow
                              : AppLocalizations.of(context)!.addAWord,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                            fontFamily: 'MomoSignature',
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        // Champs de saisie
                        _buildInputRow(
                          _sourceLanguage,
                          (value) => setState(() => _sourceLanguage = value!),
                          _wordController, // Pass controller
                          widget.languageDropdownEnabled,
                          postItColor,
                        ),
                        const SizedBox(height: 16),
                        _buildInputRow(
                          _targetLanguage,
                          (value) => setState(() => _targetLanguage = value!),
                          _translationController, // Pass controller
                          widget.languageDropdownEnabled,
                          postItColor,
                        ),
                        const SizedBox(height: 24),
                        // Boutons d'action
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildPostItButton(
                              context,
                              label: widget.isEditPopup
                                  ? AppLocalizations.of(context)!.remove
                                  : AppLocalizations.of(context)!.cancel,
                              onPressed: () {
                                _setConfirmButton(
                                    widget.isEditPopup ? 'delete' : 'cancel');
                                Navigator.of(context).pop();
                              },
                              isPrimary: false,
                              postItColor: postItColor,
                            ),
                            _buildPostItButton(
                              context,
                              label: widget.isEditPopup ? AppLocalizations.of(context)!.edit : AppLocalizations.of(context)!.add,
                              onPressed: () {
                                _setConfirmButton(
                                    widget.isEditPopup ? 'edit' : 'add');
                                Navigator.of(context).pop();
                              },
                              isPrimary: true,
                              postItColor: postItColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostItButton(
    BuildContext context, {
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
    required Color postItColor,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: isPrimary
            ? _getDarkerShade(postItColor, 0.9)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(
            color: _getDarkerShade(postItColor, 0.3),
            width: 1,
          ),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }

  Widget _buildInputRow(
    String languageValue,
    Function(String?) onLanguageChanged,
    TextEditingController controller,
    bool languageDropdownEnabled,
    Color postItColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: _getDarkerShade(postItColor, 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Dropdown de langue
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(4),
            ),
            child: DropdownButton<String>(
              isExpanded: true,
              value: languageValue,
              underline: const SizedBox(),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade800,
              ),
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
                  child: Text(        
                    AppLocalizations.of(context)!.getTranslatedLanguageName(key),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          // Champ de texte
          TextField(
            controller: controller,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey.shade800,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}