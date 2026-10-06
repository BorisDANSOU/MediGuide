import '../../domain/entities/health_task_entity.dart';
import '../../domain/repositories/health_tasks_repository.dart';
import '../datasources/health_tasks_local_ds.dart';

class HealthTasksRepoImpl implements HealthTasksRepository {
  const HealthTasksRepoImpl(this.localDataSource);

  final HealthTasksLocalDataSource localDataSource;

  @override
  Future<List<HealthTaskEntity>> getHealthTasks() {
    return localDataSource.loadHealthTasks();
  }

  @override
  Future<HealthTaskEntity> completeTask(String taskId) async {
    final tasks = await localDataSource.loadHealthTasks();
    final task = tasks.firstWhere((t) => t.id == taskId);
    return task.copyWith(
      isCompleted: true,
      completedDate: DateTime.now(),
    );
  }

  @override
  Future<List<HealthTaskEntity>> getTasksByCategory(
    HealthTaskCategory category,
  ) async {
    final tasks = await localDataSource.loadHealthTasks();
    return tasks.where((t) => t.category == category).toList();
  }

  @override
  Future<List<HealthTaskEntity>> getUrgentTasks() async {
    final tasks = await localDataSource.loadHealthTasks();
    return tasks
        .where((t) =>
            (t.priority == HealthTaskPriority.urgent ||
                t.priority == HealthTaskPriority.high) &&
            !t.isCompleted)
        .toList();
  }

  @override
  Future<List<HealthTaskEntity>> getOverdueTasks() async {
    final tasks = await localDataSource.loadHealthTasks();
    final now = DateTime.now();
    return tasks
        .where((t) => t.dueDate.isBefore(now) && !t.isCompleted)
        .toList();
  }
}
