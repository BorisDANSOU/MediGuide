import 'package:flutter/foundation.dart';

/// Position et repère visuel de l'utilisateur.
///
/// Conforme à la carte « VOTRE REPÈRE POUR LES SECOURS » de la maquette :
/// nom du quartier, repère visuel, précision GPS, coordonnées.
@immutable
class UserLocationEntity {
  const UserLocationEntity({
    required this.neighborhood,
    required this.landmark,
    required this.lat,
    required this.lng,
    required this.accuracyM,
  });

  /// Nom du quartier (ex : « Cocody, Carrefour Duncan »).
  final String neighborhood;

  /// Repère visuel à communiquer aux secours
  /// (ex : « Près de la Pharmacie des Étoiles »).
  final String landmark;

  /// Latitude WGS-84.
  final double lat;

  /// Longitude WGS-84.
  final double lng;

  /// Précision GPS en mètres (ex : 6 → badge « Précision 6m »).
  final int accuracyM;
}
