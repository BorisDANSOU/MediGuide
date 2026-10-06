import 'package:flutter_test/flutter_test.dart';
import 'package:mediguid/features/emergency/domain/entities/emergency_number_entity.dart';
import 'package:mediguid/features/emergency/domain/repositories/emergency_repository.dart';
import 'package:mediguid/features/emergency/presentation/controllers/emergency_provider.dart';

void main() {
  test('loads emergency numbers for the requested country', () async {
    const numbers = [
      EmergencyNumberEntity(
        id: 'ci-samu',
        name: 'SAMU',
        number: '185',
        country: 'Côte d’Ivoire',
      ),
    ];
    final repository = _FakeEmergencyRepository(numbers: numbers);
    final provider = EmergencyProvider(repository);

    await provider.loadForCountry('Côte d’Ivoire');

    expect(repository.requestedCountry, 'Côte d’Ivoire');
    expect(provider.numbers, numbers);
    expect(provider.isLoading, isFalse);
    expect(provider.errorMessage, isNull);
    provider.dispose();
  });

  test('exposes a generic error when loading numbers fails', () async {
    final provider = EmergencyProvider(
      _FakeEmergencyRepository(error: Exception('private detail')),
    );

    await provider.loadForCountry('Côte d’Ivoire');

    expect(
      provider.errorMessage,
      'Impossible de charger les numéros d’urgence.',
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
  Future<List<EmergencyNumberEntity>> getEmergenciesByCountry(
    String country,
  ) async {
    requestedCountry = country;
    if (error != null) throw error!;
    return numbers;
  }
}
