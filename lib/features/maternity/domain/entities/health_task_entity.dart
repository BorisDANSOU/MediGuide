/// Tâche de santé pour le suivi de grossesse
class HealthTaskEntity {
  const HealthTaskEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.dueDate,
    required this.isCompleted,
    this.completedDate,
  });

  final String id;
  final String title;
  final String description;
  final HealthTaskCategory category;
  final HealthTaskPriority priority;
  final DateTime dueDate;
  final bool isCompleted;
  final DateTime? completedDate;

  HealthTaskEntity copyWith({
    String? id,
    String? title,
    String? description,
    HealthTaskCategory? category,
    HealthTaskPriority? priority,
    DateTime? dueDate,
    bool? isCompleted,
    DateTime? completedDate,
  }) {
    return HealthTaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      completedDate: completedDate ?? this.completedDate,
    );
  }
}

/// Catégories de tâches de santé
enum HealthTaskCategory {
  consultation, // Consultations médicales
  vaccination, // Vaccinations
  examination, // Examens et tests
  nutrition, // Nutrition et supplémentation
  safety, // Signes d'alerte et sécurité
  preparation, // Préparation accouchement
}

/// Priorité des tâches
enum HealthTaskPriority {
  low,
  medium,
  high,
  urgent,
}
