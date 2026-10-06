import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediguid/features/maternity/domain/entities/health_task_entity.dart';
import 'package:mediguid/features/maternity/domain/repositories/health_tasks_repository.dart';
import 'package:mediguid/features/maternity/presentation/pages/health_tasks_page.dart';

void main() {
  testWidgets('shows guest-local tasks and persists completion through repo', (
    WidgetTester tester,
  ) async {
    final repository = _FakeHealthTasksRepository();
    await tester.pumpWidget(
      MaterialApp(home: HealthTasksPage(repository: repository)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Données locales · enregistrées sur cet appareil'), findsOneWidget);
    expect(find.text('CPN 1'), findsOneWidget);
    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();

    expect(repository.completedIds, ['cpn1']);
    expect(find.text('1/1'), findsOneWidget);
  });
}

class _FakeHealthTasksRepository implements HealthTasksRepository {
  final completedIds = <String>[];
  final tasks = [
    HealthTaskEntity(
      id: 'cpn1',
      title: 'CPN 1',
      description: 'Première consultation',
      category: HealthTaskCategory.consultation,
      priority: HealthTaskPriority.high,
      dueDate: DateTime(2026, 11, 1),
      isCompleted: false,
    ),
  ];

  @override
  Future<List<HealthTaskEntity>> getHealthTasks() async {
    return [
      for (final task in tasks)
        task.copyWith(isCompleted: completedIds.contains(task.id)),
    ];
  }

  @override
  Future<HealthTaskEntity> completeTask(String taskId) async {
    completedIds.add(taskId);
    return (await getHealthTasks()).single;
  }

  @override
  Future<List<HealthTaskEntity>> getTasksByCategory(
    HealthTaskCategory category,
  ) async =>
      tasks.where((task) => task.category == category).toList();

  @override
  Future<List<HealthTaskEntity>> getUrgentTasks() async => tasks;

  @override
  Future<List<HealthTaskEntity>> getOverdueTasks() async => tasks;
}
