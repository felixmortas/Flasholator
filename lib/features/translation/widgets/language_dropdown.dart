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
    return Transform(
      // Légère rotation pour effet post-it collé
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001) // Perspective
        ..rotateX(-0.015) // Courbure légère vers le haut
        ..rotateZ(0.008), // Très légère inclinaison
      alignment: Alignment.bottomRight,
      child: Container(
        decoration: BoxDecoration(
          // Couleur jaune post-it classique
          color: const Color(0xFFFFF59D),
          // Coins légèrement arrondis
          borderRadius: BorderRadius.circular(4),
          // Ombres pour effet collé au cahier
          boxShadow: [
            // Ombre principale - effet de profondeur
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 2,
              offset: const Offset(0, 1),
              spreadRadius: 0,
            ),
            // Ombre sur le côté pour la courbure
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 4,
              offset: const Offset(2, 3),
              spreadRadius: -1,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bande adhésive épaisse en haut
            Container(
              height: 12,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.yellow.shade700.withOpacity(0.4),
                    Colors.yellow.shade600.withOpacity(0.25),
                    Colors.yellow.shade500.withOpacity(0.1),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
                // Texture de la bande adhésive
                boxShadow: [
                  BoxShadow(
                    color: Colors.yellow.shade800.withOpacity(0.15),
                    blurRadius: 1,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
            // Contenu du post-it
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedLanguage,
                  isExpanded: true,
                  dropdownColor: const Color(0xFFFFF59D),
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: Colors.grey.shade700,
                    size: 28,
                  ),
                  // Centrer l'élément sélectionné
                  selectedItemBuilder: (BuildContext context) {
                    return sortedLanguages.map((entry) {
                      return Center(
                        child: Text(
                          AppLocalizations.of(context)!
                              .getTranslatedLanguageName(entry.key),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF424242),
                            letterSpacing: 0.5,
                            fontFamily: 'MomoSignature',
                          ),
                        ),
                      );
                    }).toList();
                  },
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
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context)!
                              .getTranslatedLanguageName(entry.key),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDisabled 
                                ? Colors.grey.shade400 
                                : Colors.grey.shade800,
                            letterSpacing: 0.5,
                            fontFamily: 'MomoSignature',
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}