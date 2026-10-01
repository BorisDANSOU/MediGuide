import '../../../../core/constants/supported_locations.dart';
import '../../../../core/utils/geo_distance.dart';
import '../../domain/entities/nearby_center.dart';
import '../../domain/repositories/health_center_catalog.dart';
import '../datasources/health_center_demo_ds.dart';

class HealthCenterCatalogImpl implements HealthCenterCatalog {
  const HealthCenterCatalogImpl({
    this.dataSource = const HealthCenterDemoDataSource(),
  });

  final HealthCenterDemoDataSource dataSource;

  @override
  Future<List<NearbyCenter>> centersAround({
    required String country,
    required String city,
  }) async {
    final centers = await dataSource.loadCenters(country: country, city: city);
    // Tant que le GPS n'est pas branché, on mesure depuis le centre-ville.
    final ref = SupportedLocations.forCountry(country);

    return centers
        .map(
          (c) => NearbyCenter(
            center: c,
            distanceKm: distanceInKm(
              ref.latitude,
              ref.longitude,
              c.latitude,
              c.longitude,
            ),
          ),
        )
        .toList()
      ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
  }
}
