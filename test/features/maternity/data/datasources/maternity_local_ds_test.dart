import 'package:flutter_test/flutter_test.dart';
import 'package:mediguid/features/maternity/data/datasources/maternity_local_ds.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads the canonical vaccine and CPN reference definitions', () async {
    const dataSource = MaternityLocalDataSource();

    final vaccines = await dataSource.loadVaccines();
    final cpnSchedules = await dataSource.loadCpnSchedule();

    expect(vaccines, hasLength(11));
    expect(vaccines.first, containsPair('id', 'bcg'));
    expect(vaccines.first, isNot(contains('status')));
    expect(cpnSchedules, hasLength(4));
    expect(cpnSchedules.first, containsPair('recommendedWeek', 12));
    expect(cpnSchedules.first, isNot(contains('completed')));
  });
}
