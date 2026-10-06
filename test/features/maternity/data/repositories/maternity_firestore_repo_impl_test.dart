import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediguid/features/maternity/data/datasources/maternity_firestore_data_source.dart';
import 'package:mediguid/features/maternity/data/repositories/maternity_firestore_repo_impl.dart';

void main() {
  test('composes reference data with private progress defaults', () async {
    final dataSource = _FakeMaternityFirestoreDataSource()
      ..references['maternity_vaccines'] = [
        {
          'id': 'bcg',
          'name': 'BCG',
          'recommendedMonth': 0,
          'description': 'À la naissance',
        },
      ]
      ..references['maternity_cpn_schedules'] = [
        {'id': 'cpn1', 'name': 'CPN 1', 'recommendedWeek': 12},
      ];
    final repository = MaternityFirestoreRepoImpl(
      uid: 'user-a',
      dataSource: dataSource,
    );

    final vaccines = await repository.getVaccinationSchedule();
    final cpn = await repository.getCpnSchedule();

    expect(vaccines.single.status, isFalse);
    expect(vaccines.single.reminderAt, isNull);
    expect(cpn.single.completed, isFalse);
    expect(dataSource.readUids, everyElement('user-a'));
  });

  test('writes only owner progress documents and timestamp values', () async {
    final dataSource = _FakeMaternityFirestoreDataSource();
    final repository = MaternityFirestoreRepoImpl(
      uid: 'user-a',
      dataSource: dataSource,
    );
    final reminderAt = DateTime(2026, 10, 12);

    await repository.setVaccineCompleted('bcg', true);
    await repository.setCpnCompleted('cpn1', true);
    await repository.setVaccineReminder('bcg', reminderAt);

    expect(dataSource.writes.map((write) => write.collection), [
      'vaccine_progress',
      'cpn_progress',
      'vaccine_progress',
    ]);
    expect(dataSource.writes.every((write) => write.uid == 'user-a'), isTrue);
    expect(
      (dataSource.writes.last.fields['reminderAt'] as Timestamp).toDate(),
      reminderAt,
    );
    expect(dataSource.references, isEmpty);
  });
}

class _FakeMaternityFirestoreDataSource
    implements MaternityFirestoreDataSource {
  final Map<String, List<Map<String, dynamic>>> references = {};
  final List<String> readUids = [];
  final List<_Write> writes = [];

  @override
  Future<List<Map<String, dynamic>>> loadReferences(String collection) async {
    return references[collection] ?? const [];
  }

  @override
  Future<Map<String, Map<String, dynamic>>> loadProgress({
    required String uid,
    required String collection,
  }) async {
    readUids.add(uid);
    return const {};
  }

  @override
  Future<void> mergeProgress({
    required String uid,
    required String collection,
    required String documentId,
    required Map<String, dynamic> fields,
  }) async {
    writes.add(_Write(uid, collection, documentId, fields));
  }
}

class _Write {
  const _Write(this.uid, this.collection, this.documentId, this.fields);

  final String uid;
  final String collection;
  final String documentId;
  final Map<String, dynamic> fields;
}
