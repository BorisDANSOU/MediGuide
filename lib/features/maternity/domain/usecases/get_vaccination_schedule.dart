import '../entities/vaccine_entity.dart';
import '../repositories/maternity_repository.dart';

class GetVaccinationSchedule {
  const GetVaccinationSchedule(this.repository);

  final MaternityRepository repository;

  Future<List<VaccineEntity>> call() {
    return repository.getVaccinationSchedule();
  }
}
