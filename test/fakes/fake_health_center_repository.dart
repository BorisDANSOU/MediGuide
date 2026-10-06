import 'package:mediguid/features/health_centers/domain/entities/health_center_entity.dart';
import 'package:mediguid/features/health_centers/domain/repositories/health_center_repository.dart';

class FakeHealthCenterRepository implements HealthCenterRepository {
  FakeHealthCenterRepository({this.centers = const [], this.error});

  final List<HealthCenterEntity> centers;
  final Object? error;

  Future<List<HealthCenterEntity>> _result() async {
    if (error != null) throw error!;
    return centers;
  }

  @override
  Future<List<HealthCenterEntity>> getNearbyHealthCenters({
    required double latitude,
    required double longitude,
    double radiusInKm = 10,
  }) => _result();

  @override
  Future<List<HealthCenterEntity>> searchHealthCenters({
    String? country,
    String? city,
    String? type,
  }) => _result();
}
