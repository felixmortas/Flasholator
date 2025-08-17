import 'package:flasholator/features/shared/utils/app_localizations_helper.dart';
import 'package:flasholator/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class LanguageDropdown extends StatelessWidget {
  final String selectedLanguage;
  final String otherLanguage;
  final List<MapEntry<String, String>> sortedLanguages;
  final void Function(String?) onChanged;
  final String? label;
  final bool enabled;

  const LanguageDropdown({
    super.key,
    required this.selectedLanguage,
    required this.otherLanguage,
    required this.sortedLanguages,
    required this.onChanged,
    this.label,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedLanguage,
          isExpanded: true,
          onChanged: enabled
              ? (val) {
                  if (val != otherLanguage) {
                    onChanged(val);
                  }
                }
              : null,
          items: sortedLanguages.map((entry) {
            final isDisabled = entry.key == otherLanguage;
            return DropdownMenuItem<String>(
              value: entry.key,
              enabled: !isDisabled,
              child: Text(
                AppLocalizations.of(context)!
                    .getTranslatedLanguageName(entry.key),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  color: isDisabled ? Colors.grey : Colors.black,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
