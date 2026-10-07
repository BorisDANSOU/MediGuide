import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediguid/features/health_centers/data/datasources/health_center_remote_ds.dart';
import 'package:mediguid/features/health_centers/data/models/medical_center.dart';
import 'package:mediguid/features/health_centers/data/repositories/health_center_repo_impl.dart';
import 'package:mediguid/features/health_centers/domain/failures/health_center_access_failure.dart';

class _FakeRemoteDataSource extends HealthCenterRemoteDataSource {
  _FakeRemoteDataSource(this.centers, {this.error});

  final List<MedicalCenter> centers;
  final Object? error;
  String? requestedCountryCode;
  String? requestedCity;

  @override
  Future<List<MedicalCenter>> fetchCenters({
    String? countryCode,
    String? city,
  }) async {
    requestedCountryCode = countryCode;
    requestedCity = city;
    if (error != null) throw error!;
    return centers;
  }
}

MedicalCenter _center({
  required String id,
  String countryCode = 'BF',
  String country = 'Burkina Faso',
  String city = 'Ouagadougou',
  String type = 'hospital',
  double latitude = 12.37,
  double longitude = -1.51,
  String? phone,
}) => MedicalCenter(
  id: id,
  name: 'Centre $id',
  nameLower: 'centre $id',
  type: type,
  countryCode: countryCode,
  country: country,
  city: city,
  latitude: latitude,
  longitude: longitude,
  phone: phone,
);

void main() {
  group('HealthCenterRepositoryImpl.searchHealthCenters', () {
    test('scopes reads to the supported country code and city', () async {
      final remote = _FakeRemoteDataSource([
        _center(id: 'bf-1', phone: '+226 00 00 00'),
        _center(id: 'bf-2', type: 'clinic'),
        _center(
          id: 'tg-1',
          countryCode: 'TG',
          country: 'Togo',
          city: 'Lomé',
        ),
      ]);
      final repository = HealthCenterRepositoryImpl(remoteDataSource: remote);

      final centers = await repository.searchHealthCenters(
        country: 'Burkina Faso',
        city: 'Ouagadougou',
      );

      expect(remote.requestedCountryCode, 'BF');
      expect(remote.requestedCity, 'Ouagadougou');
      expect(centers.map((center) => center.id), ['bf-1', 'bf-2']);
      expect(centers.first.phone, '+226 00 00 00');
    });

    test('applies the optional type filter after reading the city', () async {
      final remote = _FakeRemoteDataSource([
        _center(id: 'hospital'),
        _center(id: 'clinic', type: 'clinic'),
      ]);
      final repository = HealthCenterRepositoryImpl(remoteDataSource: remote);

      final centers = await repository.searchHealthCenters(
        country: 'Burkina Faso',
        city: 'Ouagadougou',
        type: 'clinic',
      );

      expect(centers.map((center) => center.id), ['clinic']);
    });

    test('keeps a successful empty query empty', () async {
      final repository = HealthCenterRepositoryImpl(
        remoteDataSource: _FakeRemoteDataSource(const []),
      );

      expect(await repository.searchHealthCenters(city: 'Ouagadougou'), isEmpty);
    });

    test('converts permission denied to an access failure', () async {
      final repository = HealthCenterRepositoryImpl(
        remoteDataSource: _FakeRemoteDataSource(
          const [],
          error: FirebaseException(
            plugin: 'cloud_firestore',
            code: 'permission-denied',
          ),
        ),
      );

      await expectLater(
        repository.searchHealthCenters(country: 'Togo', city: 'Lomé'),
        throwsA(isA<HealthCenterAccessFailure>()),
      );
    });

    test('propagates other Firebase errors', () async {
      final error = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'unavailable',
      );
      final repository = HealthCenterRepositoryImpl(
        remoteDataSource: _FakeRemoteDataSource(const [], error: error),
      );

      await expectLater(
        repository.searchHealthCenters(country: 'Togo', city: 'Lomé'),
        throwsA(same(error)),
      );
    });
  });

  test('keeps radius behavior for nearby center reads', () async {
    final repository = HealthCenterRepositoryImpl(
      remoteDataSource: _FakeRemoteDataSource([
        _center(id: 'near', latitude: 0.005, longitude: 0),
        _center(id: 'far', latitude: 1, longitude: 1),
      ]),
    );

    final centers = await repository.getNearbyHealthCenters(
      latitude: 0,
      longitude: 0,
      radiusInKm: 1,
    );

    expect(centers.map((center) => center.id), ['near']);
  });
}
