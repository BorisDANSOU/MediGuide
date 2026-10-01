import '../entities/emergency_number_entity.dart';

abstract class EmergencyRepository {
  Future<List<EmergencyNumberEntity>> getEmergenciesByCountry(String country);
}
