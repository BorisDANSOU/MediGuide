import 'package:latlong2/latlong.dart';

import '../../../../core/constants/supported_locations.dart';
import '../../domain/entities/health_center_entity.dart';
import '../../domain/repositories/health_center_repository.dart';

/// Repository de DÉMONSTRATION
class DemoHealthCenterRepository implements HealthCenterRepository {
  const DemoHealthCenterRepository();

  // Décalages (en degrés) autour du centre-ville, pour étaler les points
  static const List<({String type, double dLat, double dLng})> _spots = [
    (type: 'hospital', dLat: 0.012, dLng: -0.010),
    (type: 'hospital', dLat: -0.020, dLng: 0.018),
    (type: 'clinic', dLat: 0.006, dLng: 0.016),
    (type: 'clinic', dLat: -0.010, dLng: -0.014),
    (type: 'pharmacy', dLat: 0.002, dLng: -0.004),
    (type: 'pharmacy', dLat: -0.004, dLng: 0.008),
    (type: 'pharmacy', dLat: 0.016, dLng: 0.004),
  ];

  static String _labelFor(String type) => switch (type) {
    'hospital' => 'Hôpital',
    'clinic' => 'Clinique',
    _ => 'Pharmacie',
  };

  /// Fabrique la liste complète : 7 centres fictifs par ville supportée
  List<HealthCenterEntity> _all() {
    final centers = <HealthCenterEntity>[];
    for (final loc in SupportedLocations.all) {
      var n = 0;
      for (final spot in _spots) {
        n++;
        centers.add(
          HealthCenterEntity(
            id: 'demo_${loc.city}_$n',
            name: '${_labelFor(spot.type)} démo $n - ${loc.city}',
            type: spot.type,
            latitude: loc.latitude + spot.dLat,
            longitude: loc.longitude + spot.dLng,
            city: loc.city,
            country: loc.country,
          ),
        );
      }
    }
    return centers;
  }

  @override
  Future<List<HealthCenterEntity>> getNearbyHealthCenters({
    required double latitude,
    required double longitude,
    double radiusInKm = 10,
  }) async {
    const distance = Distance();
    final origin = LatLng(latitude, longitude);
    // On garde les centres situés dans le rayon demandé
    return _all()
        .where(
          (c) =>
              distance.as(
                LengthUnit.Kilometer,
                origin,
                LatLng(c.latitude, c.longitude),
              ) <=
              radiusInKm,
        )
        .toList();
  }

  @override
  Future<List<HealthCenterEntity>> searchHealthCenters({
    String? country,
    String? city,
    String? type,
  }) async {
    // Chaque filtre à null est ignoré, comme dans le vrai repository
    return _all()
        .where(
          (c) =>
              (country == null || c.country == country) &&
              (city == null || c.city == city) &&
              (type == null || c.type == type),
        )
        .toList();
  }
}
