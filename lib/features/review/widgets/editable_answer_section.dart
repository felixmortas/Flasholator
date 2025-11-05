import 'package:flasholator/features/review/widgets/all_languages_switch.dart';
import 'package:flutter/material.dart';
import 'package:flasholator/features/review/widgets/edit_answer_overlay.dart';
import 'package:flasholator/style/bottom_overlay_styles.dart';
import 'package:flasholator/config/constants.dart';

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
    const double borderRadius = 25 * GOLDEN_NUMBER;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row avec switch et bouton edit - maintenant au-dessus
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AllLanguagesSwitch(
                  isAllLanguagesToggledNotifier: isAllLanguagesToggledNotifier,
                  onToggle: onLanguageToggle,
                ),
                IconButton(
                  onPressed: onToggleEditing,
                  icon: Icon(
                    isEditing ? Icons.keyboard_arrow_down : Icons.edit,
                    size: 28,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          // Widget ardoise avec overlay
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Container extérieur (bordure)
              Container(
                width: double.infinity,
                decoration: BottomBlockStyles.outerDecoration(
                  color: BottomBlockStyles.borderColor,
                  radius: borderRadius,
                ),
                padding: BottomBlockStyles.borderPadding,
                child: Container(
                  decoration: BottomBlockStyles.innerDecoration(
                    backgroundColor: Colors.white,
                    radius: borderRadius,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 1),
                  child: EditAnswerOverlay(
                    isExpanded: isEditing,
                    controller: editingController,
                  ),
                ),
              ),

              // Poignée centrale en haut
              TopHandle(backgroundColor: BottomBlockStyles.borderColor),

              // Coins protecteurs
              CornerProtection(isLeft: true, color: BottomBlockStyles.borderColor),
              CornerProtection(isLeft: false, color: BottomBlockStyles.borderColor),
            ],
          ),
        ],
      ),
    );
  }
}