// language_selection.dart
class LanguageSelection {
  static final LanguageSelection _instance = LanguageSelection._internal();

  String sourceLanguage = 'EN';
  String targetLanguage = 'FR';

  factory LanguageSelection() {
    return _instance;
  }

  LanguageSelection._internal();

  static LanguageSelection getInstance() {
    return _instance;
  }
}