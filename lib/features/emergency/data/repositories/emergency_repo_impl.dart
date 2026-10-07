import 'package:firebase_auth/firebase_auth.dart';
import 'package:latlong2/latlong.dart';

import '../../../health_centers/data/datasources/health_center_remote_ds.dart';
import '../../../health_centers/data/models/medical_center.dart';
import '../../domain/entities/emergency_facilities_snapshot.dart';
import '../../domain/entities/emergency_hospital_entity.dart';
import '../../domain/entities/emergency_number_entity.dart';
import '../../domain/entities/emergency_pharmacy_entity.dart';
import '../../domain/entities/user_location_entity.dart';
import '../../domain/repositories/emergency_repository.dart';
import '../datasources/emergency_local_ds.dart';

class EmergencyRepositoryImpl implements EmergencyRepository {
  EmergencyRepositoryImpl(
    this.localDataSource, {
    HealthCenterRemoteDataSource? remoteDataSource,
    bool Function()? isAuthenticated,
  }) : _remoteDataSource = remoteDataSource ?? HealthCenterRemoteDataSource(),
       _isAuthenticated = isAuthenticated ?? _hasSignedInUser;

  final EmergencyLocalDataSource localDataSource;
  final HealthCenterRemoteDataSource _remoteDataSource;
  final bool Function() _isAuthenticated;

  static bool _hasSignedInUser() => FirebaseAuth.instance.currentUser != null;

  @override
  Stream<EmergencyFacilitiesSnapshot> watchFacilities({
    required String countryCode,
    required String city,
    required double lat,
    required double lng,
  }) async* {
    try {
      if (!_isAuthenticated()) {
        yield await _loadLocalFacilities(countryCode, lat, lng);
        return;
      }

      await for (final centers in _remoteDataSource.watchCenters(
        countryCode: countryCode,
        city: city,
      )) {
        yield _fromMedicalCenters(centers, lat, lng);
      }
    } on FirebaseException catch (error) {
      if (!_isRecoverableFirestoreError(error.code)) rethrow;
      yield await _loadLocalFacilities(countryCode, lat, lng);
    }
  }

  bool _isRecoverableFirestoreError(String code) =>
      code == 'permission-denied' ||
      code == 'unavailable' ||
      code == 'network-request-failed' ||
      code == 'no-app';

  Future<EmergencyFacilitiesSnapshot> _loadLocalFacilities(
    String countryCode,
    double lat,
    double lng,
  ) async {
    final results = await Future.wait([
      localDataSource.loadNearbyHospitals(
        lat: lat,
        lng: lng,
        countryCode: countryCode,
      ),
      localDataSource.loadNearbyPharmacies(
        lat: lat,
        lng: lng,
        countryCode: countryCode,
      ),
    ]);
    return EmergencyFacilitiesSnapshot(
      hospitals: results[0] as List<EmergencyHospitalEntity>,
      pharmacies: results[1] as List<EmergencyPharmacyEntity>,
      source: EmergencyFacilitiesSource.localFallback,
    );
  }

  EmergencyFacilitiesSnapshot _fromMedicalCenters(
    List<MedicalCenter> centers,
    double lat,
    double lng,
  ) {
    const distance = Distance();
    final origin = LatLng(lat, lng);
    final hospitals = <EmergencyHospitalEntity>[];
    final pharmacies = <EmergencyPharmacyEntity>[];

    for (final center in centers) {
      final location = LatLng(center.latitude, center.longitude);
      final distanceKm = distance.as(LengthUnit.Kilometer, origin, location);

      if (center.type == 'hospital') {
        hospitals.add(
          EmergencyHospitalEntity(
            id: center.id,
            name: center.name,
            phone: center.phone,
            country: center.countryCode,
            lat: center.latitude,
            lng: center.longitude,
            distanceKm: distanceKm,
            isOpen24h: center.is24h,
          ),
        );
      } else if (center.type == 'pharmacy' && center.isGuard) {
        pharmacies.add(
          EmergencyPharmacyEntity(
            id: center.id,
            name: center.name,
            address: center.address,
            phone: center.phone,
            country: center.countryCode,
            lat: center.latitude,
            lng: center.longitude,
            distanceM: distance.as(LengthUnit.Meter, origin, location).round(),
            isOnDuty: center.isGuard,
          ),
        );
      }
    }

    hospitals.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    pharmacies.sort((a, b) => a.distanceM.compareTo(b.distanceM));
    return EmergencyFacilitiesSnapshot(
      hospitals: hospitals,
      pharmacies: pharmacies,
      source: EmergencyFacilitiesSource.firestore,
    );
  }

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
