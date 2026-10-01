import '../entities/emergency_number_entity.dart';
import '../repositories/emergency_repository.dart';

class GetEmergenciesByCountry {
  const GetEmergenciesByCountry(this.repository);

  final EmergencyRepository repository;

  Future<List<EmergencyNumberEntity>> call(String country) {
    return repository.getEmergenciesByCountry(country);
  }
}
