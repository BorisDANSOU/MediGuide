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
    return const [
      CpnEntity(id: 'cpn1', name: 'CPN 1', month: 1, completed: false),
      CpnEntity(id: 'cpn2', name: 'CPN 2', month: 2, completed: false),
      CpnEntity(id: 'cpn3', name: 'CPN 3', month: 3, completed: false),
    ];
  }
}
