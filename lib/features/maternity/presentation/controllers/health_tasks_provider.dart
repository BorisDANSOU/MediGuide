import 'package:flutter/foundation.dart';

import '../../domain/entities/health_task_entity.dart';
import '../../domain/repositories/health_tasks_repository.dart';

class HealthTasksProvider extends ChangeNotifier {
  HealthTasksProvider(this.repository);

  HealthTasksRepository repository;

  List<HealthTaskEntity> _tasks = const [];
  List<HealthTaskEntity> get tasks => _tasks;

  List<HealthTaskEntity> _urgentTasks = const [];
  List<HealthTaskEntity> get urgentTasks => _urgentTasks;

  List<HealthTaskEntity> _overdueTasks = const [];
  List<HealthTaskEntity> get overdueTasks => _overdueTasks;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int _loadGeneration = 0;

  Future<void> replaceRepository(HealthTasksRepository value) async {
    if (identical(repository, value)) return;
    repository = value;
    _tasks = const [];
    _urgentTasks = const [];
    _overdueTasks = const [];
    _errorMessage = null;
    notifyListeners();
    await loadTasks();
  }

  void reportError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> loadTasks() async {
    final generation = ++_loadGeneration;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final tasks = await repository.getHealthTasks();
      if (generation != _loadGeneration) return;
      final now = DateTime.now();
      _tasks = tasks;
      _urgentTasks = tasks
          .where(
            (task) =>
                (task.priority == HealthTaskPriority.urgent ||
                    task.priority == HealthTaskPriority.high) &&
                !task.isCompleted,
          )
          .toList(growable: false);
      _overdueTasks = tasks
          .where((task) => task.dueDate.isBefore(now) && !task.isCompleted)
          .toList(growable: false);
    } catch (e) {
      if (generation == _loadGeneration) {
        _errorMessage = 'Erreur lors du chargement des tâches: $e';
      }
    } finally {
      if (generation == _loadGeneration) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> completeTask(String taskId) async {
    try {
      final updatedTask = await repository.completeTask(taskId);
      final index = _tasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        _tasks[index] = updatedTask;
        await loadTasks(); // Recharger pour mettre à jour les filtres
      }
    } catch (e) {
      _errorMessage = 'Erreur lors de la complétion: $e';
      notifyListeners();
    }
  }

  int get completedCount => _tasks.where((t) => t.isCompleted).length;
  int get pendingCount => _tasks.where((t) => !t.isCompleted).length;
  double get completionRate =>
      _tasks.isEmpty ? 0.0 : completedCount / _tasks.length;
}
