import '../entities/health_task_entity.dart';

abstract class HealthTasksRepository {
  /// Récupère toutes les tâches de santé
  Future<List<HealthTaskEntity>> getHealthTasks();

  /// Marque une tâche comme complétée
  Future<HealthTaskEntity> completeTask(String taskId);

  /// Récupère les tâches par catégorie
  Future<List<HealthTaskEntity>> getTasksByCategory(HealthTaskCategory category);

  /// Récupère les tâches urgentes/high priority
  Future<List<HealthTaskEntity>> getUrgentTasks();

  /// Récupère les tâches en retard
  Future<List<HealthTaskEntity>> getOverdueTasks();
}
