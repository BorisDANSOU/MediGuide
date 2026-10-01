import '../entities/health_center_entity.dart';
import '../repositories/health_center_repository.dart';

class GetNearbyHealthCenters {
  const GetNearbyHealthCenters(this.repository);

  final HealthCenterRepository repository;

  Future<List<HealthCenterEntity>> call({
    required double latitude,
    required double longitude,
    double radiusInKm = 10,
  }) {
    return repository.getNearbyHealthCenters(
      latitude: latitude,
      longitude: longitude,
      radiusInKm: radiusInKm,
    );
  }
}
