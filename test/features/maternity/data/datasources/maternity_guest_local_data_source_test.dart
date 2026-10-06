import 'package:flutter_test/flutter_test.dart';
import 'package:mediguid/features/maternity/data/datasources/maternity_guest_local_data_source.dart';
import 'package:mediguid/features/maternity/domain/entities/health_task_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('persists vaccine and CPN progress between repository operations', () async {
    const dataSource = MaternityGuestLocalDataSource();
    final reminderAt = DateTime(2026, 10, 12);

    await dataSource.setVaccineCompleted('bcg', true);
    await dataSource.setVaccineReminder('bcg', reminderAt);
    await dataSource.setCpnCompleted('cpn1', true);

    expect((await dataSource.loadVaccineProgress())['bcg'], {
      'completed': true,
      'reminderAt': reminderAt.toIso8601String(),
    });
    expect((await dataSource.loadCpnProgress())['cpn1'], {
      'completed': true,
    });
  });

  test('persists guest task dates and completion across loads', () async {
    const dataSource = MaternityGuestLocalDataSource();
    final template = _task(DateTime(2026, 11, 1));

    final firstLoad = await dataSource.loadTasks([template]);
    final completed = await dataSource.completeTask(template.id, [template]);
    final secondLoad = await dataSource.loadTasks([
      _task(DateTime(2030, 1, 1)),
    ]);

    expect(firstLoad.single.dueDate, template.dueDate);
    expect(completed.isCompleted, isTrue);
    expect(secondLoad.single.dueDate, template.dueDate);
    expect(secondLoad.single.isCompleted, isTrue);
  });
}

HealthTaskEntity _task(DateTime dueDate) => HealthTaskEntity(
  id: 'cpn1',
  title: 'CPN 1',
  description: 'Première consultation',
  category: HealthTaskCategory.consultation,
  priority: HealthTaskPriority.high,
  dueDate: dueDate,
  isCompleted: false,
);
