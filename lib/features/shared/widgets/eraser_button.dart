import 'package:flutter/material.dart';

class EraserButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final List<Color> gradientColors;
  final Color iconColor;
  final Color textColor;
  final bool isDisabled;

  const EraserButton({
    required this.onPressed,
    required this.label,
    required this.gradientColors,
    required this.iconColor,
    required this.textColor,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // Dégradé de couleur pastel comme une gomme
        gradient: isDisabled
            ? LinearGradient(
                colors: [
                  Colors.grey.shade300,
                  Colors.grey.shade200,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        // Bordure arrondie douce
        borderRadius: BorderRadius.circular(16),
        
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDisabled ? Colors.grey.shade500 : textColor,
              ),
              softWrap: false,
              overflow: TextOverflow.visible,
              maxLines: 1,
            ),
          ),
        ),
      ),
    );
  }
}