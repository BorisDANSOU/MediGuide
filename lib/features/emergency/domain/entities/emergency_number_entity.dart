import 'package:flutter/foundation.dart';

enum EmergencyCategory {
  medical,
  fire,
  police,
  poison,
  other,
}

/// Numéro d'urgence national (ex : SAMU, Police, Pompiers).
///
/// Reflète la section "Services nationaux prioritaires" de la maquette,
/// avec badges "Gratuit" / "Hors-ligne" et numéros secondaires.
@immutable
class EmergencyNumberEntity {
  const EmergencyNumberEntity({
    required this.id,
    required this.name,
    required this.number,
    required this.country,
    required this.category,
    required this.description,
    this.secondaryNumber,
    this.isFree = true,
    this.worksOffline = true,
  });

  /// UUID v4.
  final String id;

  /// Nom du service (ex : "SAMU Médical").
  final String name;

  /// Numéro principal à composer (ex : "185").
  final String number;

  /// Code ISO 3166-1 alpha-2 du pays (ex : "CI").
  final String country;

  /// Catégorie pour l'icône et le tri.
  final EmergencyCategory category;

  /// Courte description des cas de prise en charge (ex : "Coma, arrêt cardiaque...").
  final String description;

  /// Numéro alternatif en cas de ligne occupée (ex : "111").
  final String? secondaryNumber;

  /// Si `true`, un badge "Gratuit" est affiché.
  final bool isFree;

  /// Si `true`, un badge "Hors-ligne" est affiché.
  final bool worksOffline;
}
