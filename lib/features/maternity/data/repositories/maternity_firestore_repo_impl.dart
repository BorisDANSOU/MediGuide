import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/cpn_entity.dart';
import '../../domain/entities/vaccine_entity.dart';
import '../../domain/repositories/maternity_repository.dart';
import '../datasources/maternity_firestore_data_source.dart';
import '../models/vaccine_model.dart';

class MaternityFirestoreRepoImpl implements MaternityRepository {
  const MaternityFirestoreRepoImpl({
    required this.uid,
    required this.dataSource,
  });

  final String uid;
  final MaternityFirestoreDataSource dataSource;

  @override
  Future<List<VaccineEntity>> getVaccinationSchedule() async {
    final results = await Future.wait([
      dataSource.loadReferences('maternity_vaccines'),
      dataSource.loadProgress(uid: uid, collection: 'vaccine_progress'),
    ]);
    final references = results[0] as List<Map<String, dynamic>>;
    final progress =
        results[1] as Map<String, Map<String, dynamic>>;
    return references.map((reference) {
      final state = progress[reference['id']] ?? const {};
      return VaccineModel.fromJson({
        ...reference,
        'status': state['completed'] ?? false,
        'reminderAt': _readTimestamp(state['reminderAt']),
      });
    }).toList(growable: false);
  }

  @override
  Future<List<CpnEntity>> getCpnSchedule() async {
    final results = await Future.wait([
      dataSource.loadReferences('maternity_cpn_schedules'),
      dataSource.loadProgress(uid: uid, collection: 'cpn_progress'),
    ]);
    final references = results[0] as List<Map<String, dynamic>>;
    final progress =
        results[1] as Map<String, Map<String, dynamic>>;
    return references.map((reference) {
      final id = reference['id'];
      final name = reference['name'];
      final week = reference['recommendedWeek'];
      final description = reference['description'];
      final completed = progress[id]?['completed'] ?? false;
      if (id is! String ||
          name is! String ||
          week is! int ||
          week < 0 ||
          completed is! bool ||
          (description != null && description is! String)) {
        throw const FormatException('Invalid CPN schedule record in Firestore.');
      }
      return CpnEntity(
        id: id,
        name: name,
        week: week,
        completed: completed,
        description: description as String?,
      );
    }).toList(growable: false);
  }

  @override
  Future<void> setVaccineCompleted(String vaccineId, bool completed) {
    return dataSource.mergeProgress(
      uid: uid,
      collection: 'vaccine_progress',
      documentId: vaccineId,
      fields: {'completed': completed},
    );
  }

  @override
  Future<void> setCpnCompleted(String cpnId, bool completed) {
    return dataSource.mergeProgress(
      uid: uid,
      collection: 'cpn_progress',
      documentId: cpnId,
      fields: {'completed': completed},
    );
  }

  @override
  Future<void> setVaccineReminder(String vaccineId, DateTime? reminderAt) {
    return dataSource.mergeProgress(
      uid: uid,
      collection: 'vaccine_progress',
      documentId: vaccineId,
      fields: {
        if (reminderAt == null)
          'reminderAt': FieldValue.delete()
        else
          'reminderAt': Timestamp.fromDate(reminderAt),
      },
    );
  }

  DateTime? _readTimestamp(Object? value) {
    return switch (value) {
      null => null,
      Timestamp timestamp => timestamp.toDate(),
      _ => throw const FormatException('Invalid vaccine reminder timestamp.'),
    };
  }
}
