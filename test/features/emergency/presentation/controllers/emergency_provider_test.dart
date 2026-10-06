import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mediguid/features/emergency/domain/entities/emergency_facilities_snapshot.dart';
import 'package:mediguid/features/emergency/domain/entities/emergency_hospital_entity.dart';
import 'package:mediguid/features/emergency/domain/entities/emergency_number_entity.dart';
import 'package:mediguid/features/emergency/domain/entities/emergency_pharmacy_entity.dart';
import 'package:mediguid/features/emergency/domain/entities/user_location_entity.dart';
import 'package:mediguid/features/emergency/domain/repositories/emergency_repository.dart';
import 'package:mediguid/features/emergency/presentation/controllers/emergency_provider.dart';

void main() {
  test('loads emergency numbers for the requested country', () async {
    const numbers = [
      EmergencyNumberEntity(
        id: 'ci-samu',
        name: 'SAMU',
        number: '185',
        country: 'CI',
        category: EmergencyCategory.medical,
        description: 'Urgences médicales',
      ),
    ];
    final repository = _FakeEmergencyRepository(numbers: numbers);
    final provider = EmergencyProvider(repository);

    await provider.loadEmergencyData('CI', 'Abidjan');
    await Future<void>.delayed(Duration.zero);

    expect(repository.requestedCountry, 'CI');
    expect(provider.numbers, numbers);
    expect(provider.isLoading, isFalse);
    expect(provider.errorMessage, isNull);
    provider.dispose();
  });

  test('exposes a generic error when loading numbers fails', () async {
    final provider = EmergencyProvider(
      _FakeEmergencyRepository(error: Exception('private detail')),
    );

    await provider.loadEmergencyData('CI', 'Abidjan');

    expect(
      provider.errorMessage,
      'Impossible de charger les données d’urgence.',
    );
    expect(provider.errorMessage, isNot(contains('private detail')));
    expect(provider.isLoading, isFalse);
    provider.dispose();
  });

  test(
    'replaces old location stream and cancels active subscription on dispose',
    () async {
      var oldCancelled = false;
      var currentCancelled = false;
      final oldUpdates =
          StreamController<EmergencyFacilitiesSnapshot>.broadcast(
            onCancel: () => oldCancelled = true,
          );
      final currentUpdates =
          StreamController<EmergencyFacilitiesSnapshot>.broadcast(
            onCancel: () => currentCancelled = true,
          );
      final provider = EmergencyProvider(
        _FakeEmergencyRepository(
          facilitiesStreams: [oldUpdates.stream, currentUpdates.stream],
        ),
      );

      await provider.loadEmergencyData('TG', 'Lomé');
      await provider.loadEmergencyData('CI', 'Abidjan');
      await Future<void>.delayed(Duration.zero);
      expect(oldCancelled, isTrue);

      oldUpdates.add(
        EmergencyFacilitiesSnapshot(
          hospitals: [_hospital('old-location')],
          pharmacies: [],
          source: EmergencyFacilitiesSource.firestore,
        ),
      );
      currentUpdates.add(
        EmergencyFacilitiesSnapshot(
          hospitals: [_hospital('current-location')],
          pharmacies: [],
          source: EmergencyFacilitiesSource.localFallback,
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(provider.hospitals.single.id, 'current-location');
      expect(
        provider.facilitiesSource,
        EmergencyFacilitiesSource.localFallback,
      );
      expect(provider.isLoading, isFalse);
      provider.dispose();
      await Future<void>.delayed(Duration.zero);
      expect(currentCancelled, isTrue);
      await oldUpdates.close();
      await currentUpdates.close();
    },
  );
}

EmergencyHospitalEntity _hospital(String id) => EmergencyHospitalEntity(
  id: id,
  name: id,
  country: 'TG',
  lat: 6.13,
  lng: 1.22,
  distanceKm: 0,
);

class _FakeEmergencyRepository implements EmergencyRepository {
  _FakeEmergencyRepository({
    this.numbers = const [],
    this.error,
    this.facilitiesStreams = const [],
  });

  final List<EmergencyNumberEntity> numbers;
  final Object? error;
  final List<Stream<EmergencyFacilitiesSnapshot>> facilitiesStreams;
  var _streamIndex = 0;
  String? requestedCountry;

  @override
  Future<List<EmergencyNumberEntity>> getEmergencyNumbers(
    String countryCode,
  ) async {
    requestedCountry = countryCode;
    if (error != null) throw error!;
    return numbers;
  }

  @override
  Future<List<EmergencyHospitalEntity>> getNearbyHospitals({
    required double lat,
    required double lng,
    required String countryCode,
  }) async => const [];

  @override
  Future<List<EmergencyPharmacyEntity>> getNearbyPharmacies({
    required double lat,
    required double lng,
    required String countryCode,
  }) async => const [];

  @override
  Stream<EmergencyFacilitiesSnapshot> watchFacilities({
    required String countryCode,
    required String city,
    required double lat,
    required double lng,
  }) {
    if (_streamIndex < facilitiesStreams.length) {
      return facilitiesStreams[_streamIndex++];
    }
    return Stream.value(
      const EmergencyFacilitiesSnapshot(
        hospitals: [],
        pharmacies: [],
        source: EmergencyFacilitiesSource.firestore,
      ),
    );
  }

  @override
  Future<UserLocationEntity> getUserLocation({
    required String country,
    required String city,
  }) async => const UserLocationEntity(
    neighborhood: 'Centre',
    landmark: 'Place principale',
    lat: 0,
    lng: 0,
    accuracyM: 50,
  );
}
