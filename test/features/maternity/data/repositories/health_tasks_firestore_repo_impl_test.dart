import 'package:flutter_test/flutter_test.dart';
import 'package:mediguid/features/maternity/data/datasources/health_tasks_firestore_data_source.dart';
import 'package:mediguid/features/maternity/data/datasources/health_tasks_local_ds.dart';
import 'package:mediguid/features/maternity/data/repositories/health_tasks_firestore_repo_impl.dart';
import 'package:mediguid/features/maternity/domain/entities/health_task_entity.dart';

void main() {
  test(
    'delegates templates, preserves filters, and completes by stable ID',
    () async {
      final source = _FakeHealthTasksDataSource([
        _task('cpn1', completed: false),
      ]);
      final repository = HealthTasksFirestoreRepoImpl(
        dataSource: source,
        templateDataSource: const HealthTasksLocalDataSource(),
      );

      final tasks = await repository.getHealthTasks();
      final completed = await repository.completeTask('cpn1');

      expect(source.templateIds, isNotEmpty);
      expect(tasks.single.id, 'cpn1');
      expect(completed.id, 'cpn1');
      expect(source.completedId, 'cpn1');
      expect(
        (await repository.getTasksByCategory(HealthTaskCategory.consultation))
            .single
            .id,
        'cpn1',
      );
    },
  );
}

class _FakeHealthTasksDataSource implements HealthTasksFirestoreDataSource {
  _FakeHealthTasksDataSource(this.tasks);

  final List<HealthTaskEntity> tasks;
  List<String> templateIds = const [];
  String? completedId;

  @override
  String get uid => 'user-a';

  @override
  Future<List<HealthTaskEntity>> loadTasks(
    List<HealthTaskEntity> templates,
  ) async {
    templateIds = templates.map((task) => task.id).toList(growable: false);
    return tasks;
  }

  @override
  Future<HealthTaskEntity> completeTask(String taskId) async {
    completedId = taskId;
    return _task(taskId, completed: true);
  }
}

HealthTaskEntity _task(String id, {required bool completed}) =>
    HealthTaskEntity(
      id: id,
      title: id,
      description: 'Task',
      category: HealthTaskCategory.consultation,
      priority: HealthTaskPriority.high,
      dueDate: DateTime(2026, 11, 1),
      isCompleted: completed,
    );
