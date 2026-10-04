import 'package:flutter/foundation.dart';

import '../../domain/entities/health_task_entity.dart';
import '../../domain/repositories/health_tasks_repository.dart';

class HealthTasksProvider extends ChangeNotifier {
  HealthTasksProvider(this.repository);

  final HealthTasksRepository repository;

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

  Future<void> loadTasks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tasks = await repository.getHealthTasks();
      _urgentTasks = await repository.getUrgentTasks();
      _overdueTasks = await repository.getOverdueTasks();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des tâches: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
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
