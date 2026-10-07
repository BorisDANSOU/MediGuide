import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/health_task_entity.dart';
import '../../domain/repositories/health_tasks_repository.dart';
import '../controllers/health_tasks_provider.dart';
import '../maternity_repository_factory.dart';

class HealthTasksPage extends StatefulWidget {
  const HealthTasksPage({super.key, this.repository});

  final HealthTasksRepository? repository;

  @override
  State<HealthTasksPage> createState() => _HealthTasksPageState();
}

class _HealthTasksPageState extends State<HealthTasksPage> {
  late final HealthTasksProvider _provider;
  StreamSubscription<User?>? _authSubscription;
  String? _activeUid;
  bool _isGuest = true;

  @override
  void initState() {
    super.initState();
    _activeUid = MaternityRepositoryFactory.currentUid;
    _isGuest = _activeUid == null;
    final repository = widget.repository ??
        MaternityRepositoryFactory.healthTasks(uid: _activeUid);
    _provider = HealthTasksProvider(repository)..loadTasks();
    if (widget.repository == null) {
      _authSubscription = MaternityRepositoryFactory.authChanges?.listen(
        _onAuthChanged,
        onError: (Object error) {
          _provider.reportError(
            'Impossible de vérifier la session. Réessayez de recharger.',
          );
        },
      );
    }
  }

  @override
  void dispose() {
    final subscription = _authSubscription;
    if (subscription != null) unawaited(subscription.cancel());
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suivi de Santé'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _provider.loadTasks(),
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _provider,
          builder: (context, _) => Column(
            children: [
              _buildProgressCard(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _isGuest
                        ? 'Données locales · enregistrées sur cet appareil'
                        : 'Tâches synchronisées avec votre compte',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
              Expanded(
                child: _buildTasksList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progression',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${_provider.completedCount}/${_provider.tasks.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _provider.completionRate,
              minHeight: 10,
              backgroundColor: Colors.white30,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(_provider.completionRate * 100).toInt()}% complété',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList() {
    if (_provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_provider.errorMessage != null) {
      return Center(
        child: Text(
          _provider.errorMessage!,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _provider.tasks.length,
      itemBuilder: (context, index) {
        final task = _provider.tasks[index];
        return _buildTaskCard(task);
      },
    );
  }

  Widget _buildTaskCard(HealthTaskEntity task) {
    final isOverdue = task.dueDate.isBefore(DateTime.now()) && !task.isCompleted;
    final isUrgent = task.priority == HealthTaskPriority.urgent;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isOverdue ? 4 : 1,
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (value) {
            if (value == true) {
              _provider.completeTask(task.id);
            }
          },
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: isOverdue ? AppColors.emergency : AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Échéance: ${_formatDate(task.dueDate)}',
                  style: TextStyle(
                    color: isOverdue ? AppColors.emergency : AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                if (isUrgent) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.emergency,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'URGENT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: _buildPriorityIcon(task.priority),
      ),
    );
  }

  Widget _buildPriorityIcon(HealthTaskPriority priority) {
    switch (priority) {
      case HealthTaskPriority.urgent:
        return const Icon(Icons.priority_high, color: AppColors.emergency);
      case HealthTaskPriority.high:
        return const Icon(Icons.arrow_upward, color: AppColors.info);
      case HealthTaskPriority.medium:
        return const Icon(Icons.remove, color: AppColors.info);
      case HealthTaskPriority.low:
        return const Icon(Icons.arrow_downward, color: AppColors.textSecondary);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _onAuthChanged(User? user) {
    final uid = user?.uid;
    if (!mounted || uid == _activeUid) return;
    _activeUid = uid;
    _isGuest = uid == null;
    unawaited(
      _provider.replaceRepository(
        MaternityRepositoryFactory.healthTasks(uid: uid),
      ),
    );
    setState(() {});
  }
}
