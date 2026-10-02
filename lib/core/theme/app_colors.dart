import 'package:flutter/material.dart';

/// Palette MediGuide
class AppColors {
  AppColors._(); // Classe utilitaire : on empêche de l'instancier

  // --- Vert : couleur principale (santé) ---
  static const Color primary = Color(0xFF00634C); // Boutons, onglet actif
  static const Color brand = Color(0xFF0A7E62); // Logo, Splash
  static const Color mint = Color(0xFF95F5D2); // Puces « Ouvert 24h »
  static const Color mintSoft = Color(0xFFDFFCF2); // Fonds verts très clairs

  // --- Rouge : urgence ---
  static const Color emergency = Color(0xFFD22E2E); // FAB, bandeaux, SAMU
  static const Color emergencyDark = Color(0xFFAE0F19); // Badges, Maternité
  static const Color emergencySoft = Color(0xFFFFDAD6); // Fonds rouges clairs
  static const Color onEmergencySoft = Color(0xFF410003);

  // --- Bleu : itinéraires et actions secondaires ---
  static const Color info = Color(0xFF296198); // « Itinéraire », « Composer »
  static const Color infoSoft = Color(0xFFD2E4FF); // Bandeaux d'information

  // --- Fonds, surfaces et textes ---
  static const Color background = Color(0xFFF9F9FF); // Fond des écrans
  static const Color surface = Colors.white; // Cartes, barres
  static const Color surfaceLow = Color(0xFFF0F3FF); // Sections claires
  static const Color surfaceHigh = Color(
    0xFFE7EEFF,
  ); // Tuiles, boutons secondaires
  static const Color textPrimary = Color(0xFF111C2D);
  static const Color textSecondary = Color(0xFF3E4944);
  static const Color outline = Color(0xFFC3C6CB); // Contours
}
