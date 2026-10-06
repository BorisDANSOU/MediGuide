import '../entities/cpn_entity.dart';
import '../entities/vaccine_entity.dart';

abstract class MaternityRepository {
  Future<List<VaccineEntity>> getVaccinationSchedule();
  Future<List<CpnEntity>> getCpnSchedule();
  Future<void> setVaccineCompleted(String vaccineId, bool completed);
  Future<void> setCpnCompleted(String cpnId, bool completed);
  Future<void> setVaccineReminder(String vaccineId, DateTime? reminderAt);
}
