// Translate tab widget with a language selector, a text field for the word to translate, a text label to display the translation and a button to translate the word.
import 'package:flutter/material.dart';
import '../../core/services/flashcards_collection.dart';
import '../../core/services/deepl_translator.dart';
import '../shared/utils/language_selection.dart';
import '../../config/constants.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../shared/dialogs/cancel_dialog.dart';

class TranslateTab extends StatefulWidget {
  final FlashcardsCollection flashcardsCollection;
  final DeeplTranslator deeplTranslator;
  final Function(Map<dynamic, dynamic>) addRow;
  final Function() updateQuestionText;

  const TranslateTab({
    Key? key,
    required this.flashcardsCollection,
    required this.deeplTranslator,
    required this.addRow,
    required this.updateQuestionText,
  }) : super(key: key);

  @override
  State<TranslateTab> createState() => _TranslateTabState();
}

class _TranslateTabState extends State<TranslateTab> {
  final languageSelection = LanguageSelection();
  String _wordToTranslate = '';
  String _translatedWord = '';
  bool isTranslateButtonDisabled = true;
  bool isAddButtonDisabled = true;
  String _lastTranslatedWord = '';
  String _sourceLanguage = '';
  String _targetLanguage = '';

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _controller.removeListener(_updateButtonState);
    _controller.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    setState(() {
      isTranslateButtonDisabled =
          _controller.text.isEmpty || _controller.text == _lastTranslatedWord;
    });
  }

  void _onLanguageChange(String newValue) {
    setState(() {
      _translatedWord = '';
      _lastTranslatedWord = '';
      isAddButtonDisabled = true;
      _updateButtonState();
      // languageSelection.targetLanguage = newValue;
    });
  }

  void _swapContent() {
    setState(() {
      final String tmp = languageSelection.sourceLanguage;
      languageSelection.sourceLanguage = languageSelection.targetLanguage;
      languageSelection.targetLanguage = tmp;
    });
  }

  Future<void> _translate() async {
    isTranslateButtonDisabled = true;
    try {
      String translation = await widget.deeplTranslator.translate(
        // Version traduction locale
        _wordToTranslate,
        languageSelection.targetLanguage,
        languageSelection.sourceLanguage,
      );
      setState(() {
        _translatedWord = translation;
        _lastTranslatedWord = _wordToTranslate;
        _sourceLanguage = languageSelection.sourceLanguage;
        _targetLanguage = languageSelection.targetLanguage;
        isAddButtonDisabled = false;
        isTranslateButtonDisabled = true;
      });
    } catch (e) {
      print('Error translating text: $e');
    } finally {
      _updateButtonState();
    }
  }

  Future<void> _addFlashcard() async {
    if (_wordToTranslate != '' &&
        _translatedWord != '' &&
        _translatedWord != 'Erreur de connexion' &&
        !await widget.flashcardsCollection
            .checkIfFlashcardExists(_wordToTranslate, _translatedWord)) {
      _wordToTranslate = _wordToTranslate.toLowerCase()[0].toUpperCase() +
          _wordToTranslate.toLowerCase().substring(1);
      _translatedWord = _translatedWord.toLowerCase()[0].toUpperCase() +
          _translatedWord.toLowerCase().substring(1);

      widget.addRow({
        'front': _wordToTranslate,
        'back': _translatedWord,
        'sourceLang': _sourceLanguage,
        'targetLang': _targetLanguage,
      });
      Future<bool> isCardAdded = widget.flashcardsCollection.addFlashcard(
          _wordToTranslate, _translatedWord, _sourceLanguage, _targetLanguage);

      widget.updateQuestionText();
      setState(() {
        isAddButtonDisabled = true;
      });

      // Confirm that the card was added
      Fluttertoast.showToast(
        msg: await isCardAdded ? "Carte ajoutée" : "Carte déjà ajoutée",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }

    // open cancel dialog
    CancelDialog.show(
      context,
      onCancel: () {
        widget.flashcardsCollection
            .removeFlashcard(_wordToTranslate, _translatedWord);
        // close the dialog
        Navigator.of(context).pop();
        setState(() {
          isTranslateButtonDisabled = true;
          isAddButtonDisabled = false;
        });
        _updateButtonState();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      return DropdownButton<String>(
                        value: languageSelection.sourceLanguage,
                        onChanged: (String? newValue) {
                          if (newValue != languageSelection.targetLanguage) {
                            setState(() {
                              languageSelection.sourceLanguage = newValue!;
                            });
                          }
                        },
                        isExpanded: true,
                        isDense: true,
                        items: LANGUAGES.entries
                            .map((MapEntry<String, String> entry) {
                          return DropdownMenuItem<String>(
                            value: entry.key,
                            onTap: () {
                              if (languageSelection.sourceLanguage ==
                                  entry.key) {
                                return;
                              } else if (languageSelection.sourceLanguage !=
                                      entry.key ||
                                  languageSelection.targetLanguage !=
                                      entry.key) {
                                _onLanguageChange(entry.key);
                              }
                            },
                            enabled:
                                languageSelection.targetLanguage != entry.key,
                            child: Text(
                              entry.value,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 18.0,
                                color: languageSelection.targetLanguage ==
                                        entry.key
                                    ? Colors.grey
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _swapContent();
                      });
                    },
                    child: const Icon(Icons.swap_horiz),
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      return DropdownButton<String>(
                        value: languageSelection.targetLanguage,
                        onChanged: (String? newValue) {
                          if (newValue != languageSelection.sourceLanguage) {
                            setState(() {
                              languageSelection.targetLanguage = newValue!;
                            });
                          }
                        },
                        isExpanded: true,
                        isDense: true,
                        items: LANGUAGES.entries
                            .map((MapEntry<String, String> entry) {
                          return DropdownMenuItem<String>(
                            value: entry.key,
                            onTap: () {
                              if (languageSelection.targetLanguage ==
                                  entry.key) {
                                return;
                              } else if (languageSelection.targetLanguage !=
                                      entry.key ||
                                  languageSelection.sourceLanguage !=
                                      entry.key) {
                                _onLanguageChange(entry.key);
                              }
                            },
                            enabled:
                                languageSelection.sourceLanguage != entry.key,
                            child: Text(
                              entry.value,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 18.0,
                                color: languageSelection.sourceLanguage ==
                                        entry.key
                                    ? Colors.grey
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ],
            ),
            Stack(
              alignment: Alignment.centerRight,
              children: [
                TextField(
                  textAlign: TextAlign.left,
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText:
                        'Écrivez ou collez votre texte ici pour le traduire',
                    border: OutlineInputBorder(),
                    counterText: "",
                    hintStyle: TextStyle(
                        color: Colors.grey.withOpacity(
                            0.5)), // Set hint text color to be more transparent
                  ),
                  maxLength: 100,
                  onChanged: (value) {
                    setState(() {
                      _wordToTranslate = value;
                    });
                  },
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _controller.clear();
                      _wordToTranslate = '';
                      _translatedWord = '';
                      _lastTranslatedWord = '';
                      isTranslateButtonDisabled = true;
                      isAddButtonDisabled = true;
                    });
                    _updateButtonState();
                  },
                  icon: Icon(Icons.clear),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft, // Align text to the left
              child: Text(
                _translatedWord,
                textAlign: TextAlign.left,
                style: const TextStyle(fontSize: 18.0),
              ),
            ),
            Expanded(
              child: Container(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                    child: ElevatedButton(
                  onPressed: isTranslateButtonDisabled
                      ? null
                      : () async {
                          _translate();
                        },
                  child: const Text('Traduire'),
                )),
                const SizedBox(width: 16.0),
                Expanded(
                    child: ElevatedButton(
                  onPressed: isAddButtonDisabled ? null : _addFlashcard,
                  child: const Text('Ajouter'),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
