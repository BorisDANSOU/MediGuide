import '../../../health_centers/domain/entities/nearby_center.dart';

/// Tout ce que l'écran d'accueil affiche, pour une ville donnée.
class HomeOverview {
  const HomeOverview({
    required this.country,
    required this.city,
    required this.guardPharmacies,
    required this.nearbyCenters,
  });

  final String country;
  final String city;

  /// Pharmacies de garde, de la plus proche à la plus lointaine.
  final List<NearbyCenter> guardPharmacies;

  /// Hôpitaux et cliniques, du plus proche au plus lointain.
  final List<NearbyCenter> nearbyCenters;
}
