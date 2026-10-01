import '../entities/nearby_center.dart';

/// Liste des centres d'une ville, avec leur distance, du plus proche au plus
/// lointain. Partagée par l'accueil et la recherche.
abstract class HealthCenterCatalog {
  Future<List<NearbyCenter>> centersAround({
    required String country,
    required String city,
  });
}
