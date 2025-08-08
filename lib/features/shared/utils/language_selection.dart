// language_selection.dart
import 'package:flasholator/config/constants.dart';

class LanguageSelection {
  static final LanguageSelection _instance = LanguageSelection._internal();

  String sourceLanguage = INITIAL_SOURCE_LANGUAGE;
  String targetLanguage = INITIAL_TARGET_LANGUAGE;

  factory LanguageSelection() {
    return _instance;
  }

  LanguageSelection._internal();

  static LanguageSelection getInstance() {
    return _instance;
  }
}