import 'health_center_entity.dart';

/// Un centre de santé et sa distance par rapport à l'utilisateur.
class NearbyCenter {
  const NearbyCenter({required this.center, required this.distanceKm});

  final HealthCenterEntity center;
  final double distanceKm;
}
