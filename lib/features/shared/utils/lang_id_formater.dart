import 'package:flutter/material.dart';
import 'package:flasholator/l10n/app_localizations.dart';
import 'package:flasholator/features/shared/utils/app_localizations_helper.dart';

List<MapEntry<String, String>> getSortedLanguageEntries(
    BuildContext context, Map<String, String> languageMap) {
  late List<MapEntry<String, String>> entries = languageMap.entries.toList();

  entries.sort((a, b) => AppLocalizations.of(context)!
      .getTranslatedLanguageName(a.key)
      .compareTo(
        AppLocalizations.of(context)!.getTranslatedLanguageName(b.key),
      ));

  return entries;
}
