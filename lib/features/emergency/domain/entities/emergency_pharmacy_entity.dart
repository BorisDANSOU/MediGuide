import 'package:flutter/foundation.dart';

/// Pharmacie ouverte en service de garde.
///
/// Conforme à la section « Pharmacies de Garde Immédiates » de la maquette :
/// puce verte, nom, adresse, distance, heure de fermeture, bouton Appeler + boussole.
@immutable
class EmergencyPharmacyEntity {
  const EmergencyPharmacyEntity({
    required this.id,
    required this.name,
    this.address,
    this.phone,
    required this.country,
    required this.lat,
    required this.lng,
    required this.distanceM,
    this.closeTime,
    this.isOnDuty = false,
  });

  /// UUID v4.
  final String id;

  /// Nom de la pharmacie (ex : « Pharmacie Sainte-Cécile »).
  final String name;

  /// Adresse / repère (ex : « Cocody Deux-Plateaux, face ENA »).
  final String? address;

  /// Numéro à afficher et à appeler (ex : « +225 27 22 41 55 »).
  final String? phone;

  /// Code ISO 3166-1 alpha-2 du pays (ex : « CI », « TG », « BF »).
  final String country;

  /// Latitude WGS-84.
  final double lat;

  /// Longitude WGS-84.
  final double lng;

  /// Distance depuis l'utilisateur, en **mètres** (affiché « À 650 m »).
  final int distanceM;

  /// Heure de fermeture affichée (ex : « Ouvert jusqu'à 08h00 demain »).
  final String? closeTime;

  /// `true` → puce verte animée « Service de garde actif ».
  final bool isOnDuty;
}
