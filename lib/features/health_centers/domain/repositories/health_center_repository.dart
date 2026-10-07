import '../entities/health_center_entity.dart';

abstract class HealthCenterRepository {
  Future<List<HealthCenterEntity>> getNearbyHealthCenters({
    required double latitude,
    required double longitude,
    double radiusInKm = 10,
  });

  Future<List<HealthCenterEntity>> searchHealthCenters({
    String? country,
    String? city,
    String? type,
  });
}
