// app_colors.dart
// Ce fichier contient la palette de couleurs de l'application.

import 'package:flutter/material.dart';

class AppColors {
  // Couleurs principales
  static const Color primary = Color(0xFFF6C61E); // Rose principal des boutons
  static const Color secondary = Color(0xFF5E5CE5); // Une couleur secondaire (non visible mais bon à avoir)
  static const Color postit = Color(0xFFFFF59D); // Couleur d'accentuation (jaune vif)
  
  // Couleurs de fond
  static const Color background = Color(0xFFF6C61E); // Blanc cassé : FAFAF8 ou Beige sable très clair : F7F3E9
  static const Color sheetBackground = Color(0xFFF0F0F0); // Gris très clair pour les cartes
  
  // Couleurs de texte
  static const Color textDark = Color(0xFF333333); // Texte foncé
  static const Color textLight = Color(0xFF9E9E9E); // Texte plus clair/gris
  static const Color textWhite = Colors.white;

  // Couleurs neutres
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color white = Colors.white;
}
