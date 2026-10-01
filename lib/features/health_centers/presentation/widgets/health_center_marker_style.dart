import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Apparence d'un marqueur selon le type de centre : couleur, icône, libellé.
class HealthCenterMarkerStyle {
  const HealthCenterMarkerStyle({
    required this.color,
    required this.icon,
    required this.label,
  });

  final Color color;
  final IconData icon;
  final String label;

  /// Types connus, dans l'ordre d'affichage de la légende
  static const List<String> knownTypes = ['hospital', 'clinic', 'pharmacy'];

  /// Style pour un type donné
  static HealthCenterMarkerStyle forType(String type) => switch (type) {
    'hospital' => const HealthCenterMarkerStyle(
      color: AppColors.emergency,
      icon: Icons.local_hospital,
      label: 'Hôpitaux',
    ),
    'clinic' => const HealthCenterMarkerStyle(
      color: AppColors.info,
      icon: Icons.medical_services,
      label: 'Cliniques',
    ),
    'pharmacy' => const HealthCenterMarkerStyle(
      color: AppColors.primary,
      icon: Icons.local_pharmacy,
      label: 'Pharmacies',
    ),
    _ => const HealthCenterMarkerStyle(
      color: AppColors.textSecondary,
      icon: Icons.place,
      label: 'Autres',
    ),
  };
}
