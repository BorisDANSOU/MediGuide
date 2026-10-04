import 'package:latlong2/latlong.dart';

import '../../../../core/constants/supported_locations.dart';
import '../entities/nearby_center.dart';
import '../repositories/health_center_repository.dart';

/// Centres d'une ville avec leur distance, du plus proche au plus lointain.
/// Partagé par l'accueil et la recherche.
class GetCentersAround {
  const GetCentersAround(this.repository);

  final HealthCenterRepository repository;

  Future<List<NearbyCenter>> call({
    required String country,
    required String city,
  }) async {
    final centers = await repository.searchHealthCenters(
      country: country,
      city: city,
    );
    // Tant que le GPS n'est pas branché, on mesure depuis le centre-ville.
    final ref = SupportedLocations.forCountry(country);
    final origin = LatLng(ref.latitude, ref.longitude);
    const distance = Distance();

    return centers
        .map(
          (c) => NearbyCenter(
            center: c,
            distanceKm:
                distance.as(
                  LengthUnit.Meter,
                  origin,
                  LatLng(c.latitude, c.longitude),
                ) /
                1000,
          ),
        )
        .toList()
      ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
  }
}
