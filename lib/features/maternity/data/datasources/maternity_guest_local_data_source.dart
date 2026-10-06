import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/health_task_entity.dart';

class MaternityGuestLocalDataSource {
  const MaternityGuestLocalDataSource({
    Future<SharedPreferences> Function()? getPreferences,
  }) : _getPreferences = getPreferences ?? SharedPreferences.getInstance;

  static const _vaccineProgressKey = 'maternity_guest_vaccine_progress_v1';
  static const _cpnProgressKey = 'maternity_guest_cpn_progress_v1';
  static const _tasksKey = 'maternity_guest_tasks_v1';

  final Future<SharedPreferences> Function() _getPreferences;

  Future<Map<String, Map<String, dynamic>>> loadVaccineProgress() async {
    return _loadProgress(_vaccineProgressKey);
  }

  Future<Map<String, Map<String, dynamic>>> loadCpnProgress() async {
    return _loadProgress(_cpnProgressKey);
  }

  Future<void> setVaccineCompleted(String id, bool completed) async {
    await _updateProgress(_vaccineProgressKey, id, {'completed': completed});
  }

  Future<void> setCpnCompleted(String id, bool completed) async {
    await _updateProgress(_cpnProgressKey, id, {'completed': completed});
  }

  Future<void> setVaccineReminder(String id, DateTime? reminderAt) async {
    await _updateProgress(
      _vaccineProgressKey,
      id,
      {'reminderAt': reminderAt?.toIso8601String()},
    );
  }

  Future<List<HealthTaskEntity>> loadTasks(
    List<HealthTaskEntity> templates,
  ) async {
    final preferences = await _getPreferences();
    final stored = preferences.getString(_tasksKey);
    if (stored == null) {
      await _saveTasks(preferences, templates);
      return templates;
    }

    final decoded = jsonDecode(stored);
    if (decoded is! List) {
      throw const FormatException('Invalid locally stored maternity tasks.');
    }
    return decoded.map((record) {
      if (record is! Map<String, dynamic>) {
        throw const FormatException('Invalid locally stored maternity task.');
      }
      return _taskFromJson(record);
    }).toList(growable: false);
  }

  Future<HealthTaskEntity> completeTask(
    String taskId,
    List<HealthTaskEntity> templates,
  ) async {
    final tasks = await loadTasks(templates);
    final index = tasks.indexWhere((task) => task.id == taskId);
    if (index < 0) {
      throw StateError('Unknown maternity task: $taskId');
    }
    final updated = tasks[index].copyWith(
      isCompleted: true,
      completedDate: DateTime.now(),
    );
    final values = [...tasks]..[index] = updated;
    await _saveTasks(await _getPreferences(), values);
    return updated;
  }

  Future<Map<String, Map<String, dynamic>>> _loadProgress(String key) async {
    final encoded = (await _getPreferences()).getString(key);
    if (encoded == null) return {};
    final decoded = jsonDecode(encoded);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('Invalid local maternity progress for "$key".');
    }
    return decoded.map((id, record) {
      if (record is! Map<String, dynamic>) {
        throw FormatException('Invalid local maternity progress for "$id".');
      }
      return MapEntry(id, Map<String, dynamic>.from(record));
    });
  }

  Future<void> _updateProgress(
    String key,
    String id,
    Map<String, dynamic> fields,
  ) async {
    final preferences = await _getPreferences();
    final progress = await _loadProgress(key);
    progress[id] = {...?progress[id], ...fields};
    await preferences.setString(key, jsonEncode(progress));
  }

  Future<void> _saveTasks(
    SharedPreferences preferences,
    List<HealthTaskEntity> tasks,
  ) async {
    await preferences.setString(
      _tasksKey,
      jsonEncode(tasks.map(_taskToJson).toList(growable: false)),
    );
  }

  Map<String, dynamic> _taskToJson(HealthTaskEntity task) => {
    'id': task.id,
    'title': task.title,
    'description': task.description,
    'category': task.category.name,
    'priority': task.priority.name,
    'dueDate': task.dueDate.toIso8601String(),
    'isCompleted': task.isCompleted,
    'completedDate': task.completedDate?.toIso8601String(),
  };

  HealthTaskEntity _taskFromJson(Map<String, dynamic> record) {
    final id = record['id'];
    final title = record['title'];
    final description = record['description'];
    final categoryName = record['category'];
    final priorityName = record['priority'];
    final dueDate = record['dueDate'];
    final isCompleted = record['isCompleted'];
    final completedDate = record['completedDate'];
    final category = HealthTaskCategory.values
        .where((value) => value.name == categoryName)
        .firstOrNull;
    final priority = HealthTaskPriority.values
        .where((value) => value.name == priorityName)
        .firstOrNull;
    if (id is! String ||
        title is! String ||
        description is! String ||
        category == null ||
        priority == null ||
        dueDate is! String ||
        isCompleted is! bool ||
        (completedDate != null && completedDate is! String)) {
      throw const FormatException('Invalid locally stored maternity task.');
    }
    return HealthTaskEntity(
      id: id,
      title: title,
      description: description,
      category: category,
      priority: priority,
      dueDate: DateTime.parse(dueDate),
      isCompleted: isCompleted,
      completedDate: completedDate == null
          ? null
          : DateTime.parse(completedDate as String),
    );
  }
}
