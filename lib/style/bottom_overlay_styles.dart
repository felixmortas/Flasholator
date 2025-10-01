// bottom_block_styles.dart
// Styles personnalisés pour le BottomBlock avec effet de bordure organique

import 'package:flutter/material.dart';

class BottomBlockStyles {
  // Couleur de la bordure (cyan/turquoise de l'image)
  static const Color borderColor = Color(0xFF00BCD4); // Cyan
  
  // Épaisseur de la bordure
  static const double borderWidth = 12.0;
  
  // Rayon des coins arrondis
  static const double cornerRadius = 30.0;
  
  // Rayon des "protections" de coins
  static const double cornerProtectionRadius = 20.0;

  /// Décoration pour le conteneur extérieur (bordure colorée)
  static BoxDecoration outerDecoration({
    Color color = borderColor,
    double radius = cornerRadius,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(radius),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 12,
          offset: const Offset(0, -3),
        ),
      ],
    );
  }

  /// Décoration pour le conteneur intérieur (fond blanc)
  static BoxDecoration innerDecoration({
    Color backgroundColor = Colors.white,
    double radius = cornerRadius,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(radius - borderWidth / 2),
      ),
    );
  }

  /// Style pour la poignée de drag (handle en haut)
  static BoxDecoration handleDecoration({
    Color color = Colors.white,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(10),
    );
  }

  /// Padding pour simuler la bordure
  static EdgeInsets get borderPadding => const EdgeInsets.only(
        left: borderWidth,
        right: borderWidth,
        top: borderWidth,
      );

  /// Dimensions des coins protecteurs
  static const double cornerProtectionSize = 35.0;
  
  /// Offset des coins protecteurs
  static const double cornerProtectionOffset = -8.0;
}

/// Widget personnalisé pour créer l'effet de coin protecteur
class CornerProtection extends StatelessWidget {
  final bool isLeft;
  final Color color;

  const CornerProtection({
    super.key,
    required this.isLeft,
    this.color = BottomBlockStyles.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: BottomBlockStyles.cornerProtectionOffset,
      left: isLeft ? BottomBlockStyles.cornerProtectionOffset : null,
      right: !isLeft ? BottomBlockStyles.cornerProtectionOffset : null,
      child: Container(
        width: BottomBlockStyles.cornerProtectionSize,
        height: BottomBlockStyles.cornerProtectionSize,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(
            BottomBlockStyles.cornerProtectionRadius,
          ),
        ),
      ),
    );
  }
}

/// Widget pour la poignée centrale en haut
class TopHandle extends StatelessWidget {
  final Color backgroundColor;

  const TopHandle({
    super.key,
    this.backgroundColor = BottomBlockStyles.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -18,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: 80,
          height: 30,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(15),
            ),
          ),
          child: Center(
            child: Container(
              width: 35,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ),
    );
  }
}