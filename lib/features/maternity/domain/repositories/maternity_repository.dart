import '../entities/cpn_entity.dart';
import '../entities/vaccine_entity.dart';

abstract class MaternityRepository {
  Future<List<VaccineEntity>> getVaccinationSchedule();
  Future<List<CpnEntity>> getCpnSchedule();
}
