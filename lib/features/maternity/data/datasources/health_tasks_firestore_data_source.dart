import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/health_task_entity.dart';

class HealthTasksFirestoreDataSource {
  HealthTasksFirestoreDataSource({
    required this.uid,
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final String uid;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('users').doc(uid).collection('maternity_tasks');

  Future<List<HealthTaskEntity>> loadTasks(
    List<HealthTaskEntity> templates,
  ) async {
    final snapshot = await _collection.get();
    if (snapshot.docs.isEmpty) {
      if (snapshot.metadata.isFromCache) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'unavailable',
          message: 'Impossible de vérifier en ligne si les tâches maternité ont déjà été initialisées.',
        );
      }
      await _initializeIfStillEmpty(templates);
    }
    final current = await _collection.get();
    return current.docs
        .map((document) => _fromFirestore(document.id, document.data()))
        .toList(growable: false);
  }

  Future<HealthTaskEntity> completeTask(String taskId) async {
    final reference = _collection.doc(taskId);
    final result = await reference.get();
    if (!result.exists) {
      throw StateError('Unknown maternity task: $taskId');
    }
    await reference.set({
      'isCompleted': true,
      'completedDate': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    final updated = await reference.get();
    return _fromFirestore(updated.id, updated.data()!);
  }

  Future<void> _initializeIfStillEmpty(List<HealthTaskEntity> templates) async {
    final references = templates
        .map((task) => _collection.doc(task.id))
        .toList(growable: false);
    await _firestore.runTransaction((transaction) async {
      final documents = <DocumentSnapshot<Map<String, dynamic>>>[];
      for (final reference in references) {
        documents.add(await transaction.get(reference));
      }
      if (documents.any((document) => document.exists)) return;
      for (var index = 0; index < templates.length; index++) {
        transaction.set(references[index], _toFirestore(templates[index]));
      }
    });
  }

  Map<String, dynamic> _toFirestore(HealthTaskEntity task) => {
    'title': task.title,
    'description': task.description,
    'category': task.category.name,
    'priority': task.priority.name,
    'dueDate': Timestamp.fromDate(task.dueDate),
    'isCompleted': task.isCompleted,
    if (task.completedDate != null)
      'completedDate': Timestamp.fromDate(task.completedDate!),
  };

  HealthTaskEntity _fromFirestore(String id, Map<String, dynamic> data) {
    final title = data['title'];
    final description = data['description'];
    final categoryName = data['category'];
    final priorityName = data['priority'];
    final dueDate = data['dueDate'];
    final isCompleted = data['isCompleted'];
    final completedDate = data['completedDate'];
    final category = HealthTaskCategory.values
        .where((value) => value.name == categoryName)
        .firstOrNull;
    final priority = HealthTaskPriority.values
        .where((value) => value.name == priorityName)
        .firstOrNull;
    if (title is! String ||
        description is! String ||
        category == null ||
        priority == null ||
        dueDate is! Timestamp ||
        isCompleted is! bool ||
        (completedDate != null && completedDate is! Timestamp)) {
      throw FormatException('Invalid Firestore maternity task "$id".');
    }
    return HealthTaskEntity(
      id: id,
      title: title,
      description: description,
      category: category,
      priority: priority,
      dueDate: dueDate.toDate(),
      isCompleted: isCompleted,
      completedDate: (completedDate as Timestamp?)?.toDate(),
    );
  }
}
