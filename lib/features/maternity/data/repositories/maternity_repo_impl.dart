import '../../domain/entities/cpn_entity.dart';
import '../../domain/entities/vaccine_entity.dart';
import '../../domain/repositories/maternity_repository.dart';
import '../datasources/maternity_guest_local_data_source.dart';
import '../datasources/maternity_local_ds.dart';
import '../models/vaccine_model.dart';

class MaternityRepositoryImpl implements MaternityRepository {
  const MaternityRepositoryImpl(
    this.localDataSource, {
    this.guestDataSource = const MaternityGuestLocalDataSource(),
  });

  final MaternityLocalDataSource localDataSource;
  final MaternityGuestLocalDataSource guestDataSource;

  @override
  Future<List<VaccineEntity>> getVaccinationSchedule() async {
    final rawData = await localDataSource.loadVaccines();
    final progress = await guestDataSource.loadVaccineProgress();
    return rawData.map((json) {
      final state = progress[json['id']];
      return VaccineModel.fromJson({
        ...json,
        'status': state?['completed'] ?? false,
        'reminderAt': state?['reminderAt'] == null
            ? null
            : DateTime.parse(state!['reminderAt'] as String),
      });
    }).toList();
  }

  @override
  Future<List<CpnEntity>> getCpnSchedule() async {
    final rawData = await localDataSource.loadCpnSchedule();
    final progress = await guestDataSource.loadCpnProgress();
    return rawData.map((json) {
      return CpnEntity(
        id: json['id'] as String,
        name: json['name'] as String,
        week: json['recommendedWeek'] as int,
        completed: progress[json['id']]?['completed'] as bool? ?? false,
        description: json['description'] as String?,
      );
    }).toList();
  }

  @override
  Future<void> setVaccineCompleted(String vaccineId, bool completed) {
    return guestDataSource.setVaccineCompleted(vaccineId, completed);
  }

  @override
  Future<void> setCpnCompleted(String cpnId, bool completed) {
    return guestDataSource.setCpnCompleted(cpnId, completed);
  }

  @override
  Future<void> setVaccineReminder(String vaccineId, DateTime? reminderAt) {
    return guestDataSource.setVaccineReminder(vaccineId, reminderAt);
  }
}
