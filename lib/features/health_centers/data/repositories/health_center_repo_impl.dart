import 'package:firebase_core/firebase_core.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/supported_locations.dart';
import '../../domain/entities/health_center_entity.dart';
import '../../domain/failures/health_center_access_failure.dart';
import '../../domain/repositories/health_center_repository.dart';
import '../datasources/health_center_remote_ds.dart';
import '../models/medical_center.dart';

class HealthCenterRepositoryImpl implements HealthCenterRepository {
  const HealthCenterRepositoryImpl({required this.remoteDataSource});

  final HealthCenterRemoteDataSource remoteDataSource;

  @override
  Future<List<HealthCenterEntity>> getNearbyHealthCenters({
    required double latitude,
    required double longitude,
    double radiusInKm = 10,
  }) async {
    final centers = await _fetchCenters();
    const distance = Distance();
    final origin = LatLng(latitude, longitude);

    return centers
        .map(_toEntity)
        .where(
          (center) =>
              distance.as(
                LengthUnit.Kilometer,
                origin,
                LatLng(center.latitude, center.longitude),
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
    final centers = await _fetchCenters(
      countryCode: country == null
          ? null
          : SupportedLocations.isoCodeForCountry(country),
      city: city,
    );

    return centers
        .where((item) {
          final matchesCountry = country == null || item.country == country;
          final matchesCity = city == null || item.city == city;
          final matchesType = type == null || item.type == type;
          return matchesCountry && matchesCity && matchesType;
        })
        .map(_toEntity)
        .toList();
  }

  Future<List<MedicalCenter>> _fetchCenters({
    String? countryCode,
    String? city,
  }) async {
    try {
      return await remoteDataSource.fetchCenters(
        countryCode: countryCode,
        city: city,
      );
    } on FirebaseException catch (error) {
      if (error.code == 'permission-denied') {
        throw const HealthCenterAccessFailure();
      }
      rethrow;
    }
  }

  HealthCenterEntity _toEntity(MedicalCenter center) => HealthCenterEntity(
    id: center.id,
    name: center.name,
    type: center.type,
    latitude: center.latitude,
    longitude: center.longitude,
    city: center.city,
    country: center.country,
    phone: center.phone,
    address: center.address,
    openingHours: center.openingHours,
    is24h: center.is24h,
    isGuard: center.isGuard,
  );
}
