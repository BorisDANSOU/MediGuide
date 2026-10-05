import 'package:flutter_test/flutter_test.dart';
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
}

class _FakeEmergencyRepository implements EmergencyRepository {
  _FakeEmergencyRepository({this.numbers = const [], this.error});

  final List<EmergencyNumberEntity> numbers;
  final Object? error;
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
