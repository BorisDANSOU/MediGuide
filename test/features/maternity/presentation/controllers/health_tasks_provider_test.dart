import 'package:flutter_test/flutter_test.dart';
import 'package:mediguid/features/maternity/domain/entities/health_task_entity.dart';
import 'package:mediguid/features/maternity/domain/repositories/health_tasks_repository.dart';
import 'package:mediguid/features/maternity/presentation/controllers/health_tasks_provider.dart';

void main() {
  test('loads, completes, and derives task progress from repository state', () async {
    final repository = _FakeHealthTasksRepository([_task()]);
    final provider = HealthTasksProvider(repository);

    await provider.loadTasks();
    expect(provider.tasks.single.isCompleted, isFalse);

    await provider.completeTask('cpn1');

    expect(provider.tasks.single.isCompleted, isTrue);
    expect(provider.completedCount, 1);
    expect(provider.pendingCount, 0);
    expect(provider.completionRate, 1);
    provider.dispose();
  });

  test('clears prior account tasks when the repository changes', () async {
    final first = _FakeHealthTasksRepository([_task()]);
    final second = _FakeHealthTasksRepository([
      _task().copyWith(id: 'echo1', title: 'Échographie'),
    ]);
    final provider = HealthTasksProvider(first);
    await provider.loadTasks();

    await provider.replaceRepository(second);

    expect(provider.tasks.map((task) => task.id), ['echo1']);
    expect(provider.errorMessage, isNull);
    provider.dispose();
  });
}

class _FakeHealthTasksRepository implements HealthTasksRepository {
  _FakeHealthTasksRepository(this.tasks);

  List<HealthTaskEntity> tasks;

  @override
  Future<List<HealthTaskEntity>> getHealthTasks() async => tasks;

  @override
  Future<HealthTaskEntity> completeTask(String taskId) async {
    final index = tasks.indexWhere((task) => task.id == taskId);
    final completed = tasks[index].copyWith(
      isCompleted: true,
      completedDate: DateTime(2026, 10, 5),
    );
    tasks = [...tasks]..[index] = completed;
    return completed;
  }

  @override
  Future<List<HealthTaskEntity>> getTasksByCategory(
    HealthTaskCategory category,
  ) async => tasks.where((task) => task.category == category).toList();

  @override
  Future<List<HealthTaskEntity>> getUrgentTasks() async => tasks;

  @override
  Future<List<HealthTaskEntity>> getOverdueTasks() async => tasks;
}

HealthTaskEntity _task() => HealthTaskEntity(
  id: 'cpn1',
  title: 'CPN 1',
  description: 'Consultation',
  category: HealthTaskCategory.consultation,
  priority: HealthTaskPriority.high,
  dueDate: DateTime(2026, 10, 1),
  isCompleted: false,
);
