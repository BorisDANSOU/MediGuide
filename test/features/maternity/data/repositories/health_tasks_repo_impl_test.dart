import 'package:flutter_test/flutter_test.dart';
import 'package:mediguid/features/maternity/data/datasources/health_tasks_local_ds.dart';
import 'package:mediguid/features/maternity/data/repositories/health_tasks_repo_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('persists guest task completion and due dates across repositories', () async {
    final firstRepository = HealthTasksRepoImpl(
      const HealthTasksLocalDataSource(),
    );
    final initialTasks = await firstRepository.getHealthTasks();
    final initialTask = initialTasks.first;
    await firstRepository.completeTask(initialTask.id);

    final secondRepository = HealthTasksRepoImpl(
      const HealthTasksLocalDataSource(),
    );
    final restored = (await secondRepository.getHealthTasks())
        .firstWhere((task) => task.id == initialTask.id);

    expect(restored.isCompleted, isTrue);
    expect(restored.completedDate, isNotNull);
    expect(restored.dueDate, initialTask.dueDate);
  });
}
