// language_selection.dart
import 'package:flasholator/config/constants.dart';

class LanguageSelection {
  static final LanguageSelection _instance = LanguageSelection._internal();

  String sourceLanguage = initialSourceLanguage;
  String targetLanguage = initialTargetLanguage;

  factory LanguageSelection() {
    return _instance;
  }

  LanguageSelection._internal();

  static LanguageSelection getInstance() {
    return _instance;
  }

  void reset() {
    sourceLanguage = initialSourceLanguage;
    targetLanguage = initialTargetLanguage;
  }
}
