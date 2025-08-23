import 'package:flasholator/features/review/widgets/all_languages_switch.dart';
import 'package:flutter/material.dart';
import 'package:flasholator/features/review/widgets/edit_answer_overlay.dart'; // Assure-toi que le chemin est correct

class EditableAnswerSection extends StatelessWidget {
  final bool isEditing;
  final VoidCallback onToggleEditing;
  final TextEditingController editingController;
  final ValueNotifier<bool> isAllLanguagesToggledNotifier;
  final ValueChanged<bool> onLanguageToggle;

  const EditableAnswerSection({
    super.key,
    required this.isEditing,
    required this.onToggleEditing,
    required this.editingController,
    required this.isAllLanguagesToggledNotifier,
    required this.onLanguageToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Enveloppe dans un Container pour un futur style si besoin (ex: couleur de fond)
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(height: 1),
          // --- Boutons en haut de l’overlay ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AllLanguagesSwitch(
                  isAllLanguagesToggledNotifier: isAllLanguagesToggledNotifier,
                  onToggle: onLanguageToggle,
                ),
                IconButton(
                  onPressed: onToggleEditing,
                  icon: Icon(isEditing ? Icons.keyboard_arrow_down : Icons.edit),
                ),
              ],
            ),
          ),

          // --- Overlay avec TextField ---
          EditAnswerOverlay(
            isExpanded: isEditing,
            controller: editingController,
          ),
        ],
      ),
    );
  }
}