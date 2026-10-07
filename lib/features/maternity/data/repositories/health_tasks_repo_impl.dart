import '../../domain/entities/health_task_entity.dart';
import '../../domain/repositories/health_tasks_repository.dart';
import '../datasources/maternity_guest_local_data_source.dart';
import '../datasources/health_tasks_local_ds.dart';

class HealthTasksRepoImpl implements HealthTasksRepository {
  const HealthTasksRepoImpl(
    this.localDataSource, {
    this.guestDataSource = const MaternityGuestLocalDataSource(),
  });

  final HealthTasksLocalDataSource localDataSource;
  final MaternityGuestLocalDataSource guestDataSource;

  @override
  Future<List<HealthTaskEntity>> getHealthTasks() async {
    final templates = await localDataSource.loadHealthTasks();
    return guestDataSource.loadTasks(templates);
  }

  @override
  Future<HealthTaskEntity> completeTask(String taskId) async {
    final templates = await localDataSource.loadHealthTasks();
    return guestDataSource.completeTask(taskId, templates);
  }

  @override
  Future<List<HealthTaskEntity>> getTasksByCategory(
    HealthTaskCategory category,
  ) async {
    final tasks = await getHealthTasks();
    return tasks.where((t) => t.category == category).toList();
  }

  @override
  Future<List<HealthTaskEntity>> getUrgentTasks() async {
    final tasks = await getHealthTasks();
    return tasks
        .where((t) =>
            (t.priority == HealthTaskPriority.urgent ||
                t.priority == HealthTaskPriority.high) &&
            !t.isCompleted)
        .toList();
  }

  @override
  Future<List<HealthTaskEntity>> getOverdueTasks() async {
    final tasks = await getHealthTasks();
    final now = DateTime.now();
    return tasks
        .where((t) => t.dueDate.isBefore(now) && !t.isCompleted)
        .toList();
  }
}
