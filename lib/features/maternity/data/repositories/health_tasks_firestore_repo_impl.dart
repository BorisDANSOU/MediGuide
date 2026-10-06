import '../../domain/entities/health_task_entity.dart';
import '../../domain/repositories/health_tasks_repository.dart';
import '../datasources/health_tasks_firestore_data_source.dart';
import '../datasources/health_tasks_local_ds.dart';

class HealthTasksFirestoreRepoImpl implements HealthTasksRepository {
  const HealthTasksFirestoreRepoImpl({
    required this.dataSource,
    required this.templateDataSource,
  });

  final HealthTasksFirestoreDataSource dataSource;
  final HealthTasksLocalDataSource templateDataSource;

  Future<List<HealthTaskEntity>> _loadTasks() async {
    final templates = await templateDataSource.loadHealthTasks();
    return dataSource.loadTasks(templates);
  }

  @override
  Future<List<HealthTaskEntity>> getHealthTasks() => _loadTasks();

  @override
  Future<HealthTaskEntity> completeTask(String taskId) {
    return dataSource.completeTask(taskId);
  }

  @override
  Future<List<HealthTaskEntity>> getTasksByCategory(
    HealthTaskCategory category,
  ) async {
    return (await _loadTasks())
        .where((task) => task.category == category)
        .toList(growable: false);
  }

  @override
  Future<List<HealthTaskEntity>> getUrgentTasks() async {
    return (await _loadTasks())
        .where(
          (task) =>
              (task.priority == HealthTaskPriority.urgent ||
                  task.priority == HealthTaskPriority.high) &&
              !task.isCompleted,
        )
        .toList(growable: false);
  }

  @override
  Future<List<HealthTaskEntity>> getOverdueTasks() async {
    final now = DateTime.now();
    return (await _loadTasks())
        .where((task) => task.dueDate.isBefore(now) && !task.isCompleted)
        .toList(growable: false);
  }
}
