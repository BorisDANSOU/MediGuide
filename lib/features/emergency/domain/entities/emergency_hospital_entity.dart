import 'package:flutter/foundation.dart';

/// Hôpital ou clinique avec service d'urgences.
///
/// Conforme à la section « Urgences Hospitalières » de la maquette :
/// nom, services proposés, distance, disponibilité 24/24, et image.
@immutable
class EmergencyHospitalEntity {
  const EmergencyHospitalEntity({
    required this.id,
    required this.name,
    this.phone,
    required this.country,
    required this.lat,
    required this.lng,
    required this.distanceKm,
    this.services = const [],
    this.isOpen24h = true,
    this.imageAssetPath,
  });

  /// UUID v4.
  final String id;

  /// Nom de l'établissement (ex : « CHU de Cocody »).
  final String name;

  /// Numéro de téléphone des urgences (ex : « +225 27 22 48 00 »).
  final String? phone;

  /// Code ISO 3166-1 alpha-2 du pays (ex : « CI », « TG », « BF »).
  final String country;

  /// Latitude WGS-84.
  final double lat;

  /// Longitude WGS-84.
  final double lng;

  /// Distance depuis l'utilisateur, en **kilomètres** (affiché « 1.8 km »).
  final double distanceKm;

  /// Liste des services affichés en sous-titre (ex : ["Service Urgences Adultes", "Pédiatrie & Grands Brûlés"]).
  final List<String> services;

  /// `true` → affichage du badge vert "Ouvert 24h/24".
  final bool isOpen24h;

  /// Chemin de l'image d'illustration (ex : "assets/images/chu_cocody.jpg").
  final String? imageAssetPath;
}
