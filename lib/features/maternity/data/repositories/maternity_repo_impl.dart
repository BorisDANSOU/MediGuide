import '../../domain/entities/cpn_entity.dart';
import '../../domain/entities/vaccine_entity.dart';
import '../../domain/repositories/maternity_repository.dart';
import '../datasources/maternity_local_ds.dart';
import '../models/vaccine_model.dart';

class MaternityRepositoryImpl implements MaternityRepository {
  const MaternityRepositoryImpl(this.localDataSource);

  final MaternityLocalDataSource localDataSource;

  @override
  Future<List<VaccineEntity>> getVaccinationSchedule() async {
    final rawData = await localDataSource.loadVaccines();
    return rawData.map((json) => VaccineModel.fromJson(json)).toList();
  }

  @override
  Future<List<CpnEntity>> getCpnSchedule() async {
    final rawData = await localDataSource.loadCpnSchedule();
    return rawData.map((json) {
      return CpnEntity(
        id: json['id'] as String,
        name: json['name'] as String,
        week: json['recommendedWeek'] as int,
        completed: json['completed'] as bool,
        description: json['description'] as String?,
      );
    }).toList();
  }
}
