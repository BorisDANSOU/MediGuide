import '../../domain/entities/health_center_entity.dart';
import '../../domain/repositories/health_center_repository.dart';
import '../datasources/health_center_local_ds.dart';
import '../datasources/health_center_remote_ds.dart';
import '../models/health_center_model.dart';

class HealthCenterRepositoryImpl implements HealthCenterRepository {
  const HealthCenterRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  final HealthCenterRemoteDataSource remoteDataSource;
  final HealthCenterLocalDataSource localDataSource;

  @override
  Future<List<HealthCenterEntity>> getNearbyHealthCenters({
    required double latitude,
    required double longitude,
    double radiusInKm = 10,
  }) async {
    final rawData = await remoteDataSource.fetchNearbyCenters(
      latitude: latitude,
      longitude: longitude,
      radiusInKm: radiusInKm,
    );

    return rawData.map((json) => HealthCenterModel.fromJson(json)).toList();
  }

  @override
  Future<List<HealthCenterEntity>> searchHealthCenters({
    String? country,
    String? city,
    String? type,
  }) async {
    final rawData = await localDataSource.loadCachedCenters();

    return rawData
        .where((item) {
          final matchesCountry = country == null || item['country'] == country;
          final matchesCity = city == null || item['city'] == city;
          final matchesType = type == null || item['type'] == type;
          return matchesCountry && matchesCity && matchesType;
        })
        .map((json) => HealthCenterModel.fromJson(json))
        .toList();
  }
}
