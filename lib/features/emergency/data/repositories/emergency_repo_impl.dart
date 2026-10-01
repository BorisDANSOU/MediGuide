import '../../domain/entities/emergency_number_entity.dart';
import '../../domain/repositories/emergency_repository.dart';
import '../datasources/emergency_local_ds.dart';

class EmergencyRepositoryImpl implements EmergencyRepository {
  const EmergencyRepositoryImpl(this.localDataSource);

  final EmergencyLocalDataSource localDataSource;

  @override
  Future<List<EmergencyNumberEntity>> getEmergenciesByCountry(
    String country,
  ) async {
    final data = await localDataSource.loadEmergencies();

    return data
        .where((item) => item['country'] == country)
        .map(
          (item) => EmergencyNumberEntity(
            id: '${item['name']}-${item['number']}',
            name: item['name'] as String,
            number: item['number'] as String,
            country: item['country'] as String,
          ),
        )
        .toList();
  }
}
