import '../../domain/entities/emergency_hospital_entity.dart';
import '../../domain/entities/emergency_number_entity.dart';
import '../../domain/entities/emergency_pharmacy_entity.dart';
import '../../domain/entities/user_location_entity.dart';
import '../../domain/repositories/emergency_repository.dart';
import '../datasources/emergency_local_ds.dart';

class EmergencyRepositoryImpl implements EmergencyRepository {
  const EmergencyRepositoryImpl(this.localDataSource);

  final EmergencyLocalDataSource localDataSource;

  @override
  Future<List<EmergencyNumberEntity>> getEmergencyNumbers(String countryCode) {
    return localDataSource.loadEmergencyNumbers(countryCode);
  }

  @override
  Future<List<EmergencyHospitalEntity>> getNearbyHospitals({
    required double lat,
    required double lng,
    required String countryCode,
  }) {
    return localDataSource.loadNearbyHospitals(
      lat: lat,
      lng: lng,
      countryCode: countryCode,
    );
  }

  @override
  Future<List<EmergencyPharmacyEntity>> getNearbyPharmacies({
    required double lat,
    required double lng,
    required String countryCode,
  }) {
    return localDataSource.loadNearbyPharmacies(
      lat: lat,
      lng: lng,
      countryCode: countryCode,
    );
  }

  @override
  Future<UserLocationEntity> getUserLocation({
    required String country,
    required String city,
  }) {
    return localDataSource.loadUserLocation(country: country, city: city);
  }
}
