import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/controllers/auth_providers.dart';
import '../../domain/entities/cpn_entity.dart';
import '../../domain/entities/health_task_entity.dart';
import '../../domain/repositories/health_tasks_repository.dart';
import '../../domain/repositories/maternity_repository.dart';
import '../controllers/health_tasks_provider.dart';
import '../controllers/maternity_provider.dart';
import '../maternity_repository_factory.dart';
import '../pages/health_tasks_page.dart';
import '../widgets/maternity_dashboard_widgets.dart';
import '../widgets/vaccine_card.dart';

class MaternityDashboardPage extends ConsumerStatefulWidget {
  const MaternityDashboardPage({
    super.key,
    this.repository,
    this.healthTasksRepository,
  });

  final MaternityRepository? repository;
  final HealthTasksRepository? healthTasksRepository;

  @override
  ConsumerState<MaternityDashboardPage> createState() =>
      _MaternityDashboardPageState();
}

class _MaternityDashboardPageState
    extends ConsumerState<MaternityDashboardPage> {
  late final MaternityProvider _provider;
  late final HealthTasksProvider _healthTasksProvider;
  StreamSubscription<User?>? _authSubscription;
  String? _activeUid;
  bool _isGuest = true;
  var _showBaby = false;

  @override
  void initState() {
    super.initState();
    _activeUid = MaternityRepositoryFactory.currentUid;
    _isGuest = _activeUid == null;
    final repository =
        widget.repository ??
        MaternityRepositoryFactory.maternity(uid: _activeUid);
    _provider = MaternityProvider(repository)..loadSchedules();
    final healthTasksRepository =
        widget.healthTasksRepository ??
        MaternityRepositoryFactory.healthTasks(uid: _activeUid);
    _healthTasksProvider = HealthTasksProvider(healthTasksRepository)
      ..loadTasks();
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
    _healthTasksProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authSessionProvider);
    final dossierName = user?.fullName.trim();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: Listenable.merge([_provider, _healthTasksProvider]),
          builder: (context, _) => Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MaternityDashboardHeader(
                      dossierName: dossierName == null || dossierName.isEmpty
                          ? null
                          : dossierName,
                      onSettings: () => _showMessage(
                        'Réglages indisponibles dans cette démonstration.',
                      ),
                      onProfile: () => _showMessage(
                        'Le profil sera raccordé ultérieurement.',
                      ),
                    ),
                    const SizedBox(height: 14),
                    MaternityModeTabs(
                      showBaby: _showBaby,
                      onChanged: (value) => setState(() => _showBaby = value),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isGuest
                          ? 'Mode invité : progression enregistrée sur cet appareil.'
                          : 'Progression synchronisée avec votre compte.',
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                    if (_provider.isLoading) ...[
                      const SizedBox(height: 12),
                      const LinearProgressIndicator(minHeight: 3),
                    ],
                    if (_provider.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      MaternityNotice(message: _provider.errorMessage!),
                      TextButton.icon(
                        onPressed: _provider.loadSchedules,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Réessayer'),
                      ),
                    ],
                    const SizedBox(height: 16),
                    if (_showBaby)
                      _buildBabyContent()
                    else
                      _buildPregnancyContent(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPregnancyContent() {
    final cpn = _nextCpn(_provider.cpnSchedules);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MaternityEmergencyCard(
          onEmergency: () => context.go(AppRoutes.emergency),
          onCall: () =>
              _showMessage('L’appel direct sera configuré pour votre zone.'),
        ),
        const SizedBox(height: 16),
        PregnancySummaryCard(cpn: cpn),
        const SizedBox(height: 12),
        _buildCpnProgress(),
        const SizedBox(height: 24),
        MaternitySectionHeading(
          title: 'Échéances & Examens Recommandés',
          actionLabel: 'Tout voir',
          onAction: _openHealthTasks,
        ),
        const SizedBox(height: 10),
        if (_healthTasksProvider.isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: LinearProgressIndicator(minHeight: 3),
          )
        else if (_healthTasksProvider.errorMessage != null) ...[
          MaternityNotice(message: _healthTasksProvider.errorMessage!),
          TextButton.icon(
            onPressed: _healthTasksProvider.loadTasks,
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
        ] else
          ..._buildHealthTaskCards(),
        const SizedBox(height: 24),
        const MaternitySectionHeading(
          title: 'Repères & Conseils Validés',
          icon: Icons.menu_book_outlined,
        ),
        const SizedBox(height: 2),
        Text(
          'Élaborés par le collège national des sages-femmes',
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        MaternityAdviceCard(
          imageAsset: 'assets/images/maternity_warning.jpg',
          category: 'Sécurité Vitale',
          duration: '2 min',
          title: 'Signes d’alerte du 3e trimestre nécessitant un avis immédiat',
          actionLabel: 'Lire le mémo',
          onTap: () =>
              _showMessage('Le mémo sera ajouté au contenu maternité.'),
        ),
        const SizedBox(height: 8),
        MaternityAdviceCard(
          imageAsset: 'assets/images/maternity_bag.jpg',
          category: 'Préparation',
          duration: '3 min',
          title: 'Trousse d’accouchement : les indispensables en maternité',
          actionLabel: 'Voir la liste',
          onTap: () =>
              _showMessage('La liste sera ajoutée au contenu maternité.'),
        ),
        const SizedBox(height: 8),
        MaternityAdviceCard(
          imageAsset: 'assets/images/maternity_nutrition.jpg',
          category: 'Nutrition',
          duration: '4 min',
          title: 'Alimentation et prévention de l’anémie : aliments locaux…',
          actionLabel: 'Consulter les recettes',
          onTap: () => _showMessage(
            'Les recettes seront ajoutées au contenu maternité.',
          ),
        ),
        const SizedBox(height: 24),
        MaternityListeningLine(
          onContact: () => _showMessage(
            'Les coordonnées de la ligne d’écoute seront configurées pour votre zone.',
          ),
        ),
        const SizedBox(height: 20),
        _buildHealthTasksButton(),
      ],
    );
  }

  List<Widget> _buildHealthTaskCards() {
    final tasks = _healthTasksProvider.tasks;
    final ultrasound = _taskById(tasks, 'echo3');
    final biologicalAssessment = _taskById(tasks, 'blood2');
    final vat = _nextVatTask(tasks);
    final cards = <Widget>[];

    void addCard(HealthTaskEntity? task) {
      if (task == null) return;
      if (cards.isNotEmpty) cards.add(const SizedBox(height: 8));
      cards.add(
        MaternityExamCard(
          title: task.title,
          status: task.isCompleted ? 'Déclaré fait' : 'À suivre',
          details: null,
          footer: null,
          actionLabel: 'Voir le suivi',
          onAction: _openHealthTasks,
          isComplete: task.isCompleted,
        ),
      );
    }

    addCard(ultrasound);
    addCard(biologicalAssessment);
    addCard(vat);
    return cards;
  }

  HealthTaskEntity? _taskById(List<HealthTaskEntity> tasks, String id) {
    for (final task in tasks) {
      if (task.id == id) return task;
    }
    return null;
  }

  HealthTaskEntity? _nextVatTask(List<HealthTaskEntity> tasks) {
    final firstDose = _taskById(tasks, 'vat1');
    final secondDose = _taskById(tasks, 'vat2');
    if (firstDose != null && !firstDose.isCompleted) return firstDose;
    if (secondDose != null && !secondDose.isCompleted) return secondDose;
    return secondDose ?? firstDose;
  }

  Widget _buildBabyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Suivi de mon bébé',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          _isGuest
              ? 'Calendrier vaccinal local · appareil uniquement'
              : 'Calendrier vaccinal synchronisé',
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => context.push(AppRoutes.vaccines),
          icon: const Icon(Icons.vaccines_outlined),
          label: const Text('Calendrier vaccinal complet'),
        ),
        const SizedBox(height: 8),
        if (_provider.vaccines.isEmpty)
          const MaternityNotice(message: 'Aucun vaccin prévu pour le moment.')
        else
          ..._provider.vaccines.map(
            (vaccine) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: VaccineCard(
                name: vaccine.name,
                month: vaccine.recommendedMonth,
                completed: vaccine.status,
                reminderAt: vaccine.reminderAt,
                onCompletedChanged: (completed) {
                  _provider.setVaccineCompleted(vaccine.id, completed);
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCpnProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const MaternitySectionHeading(title: 'Suivi des consultations CPN'),
        const SizedBox(height: 4),
        ..._provider.cpnSchedules.map(
          (cpn) => Card(
            margin: const EdgeInsets.only(bottom: 6),
            child: CheckboxListTile(
              value: cpn.completed,
              title: Text(cpn.name),
              subtitle: Text('Semaine recommandée : ${cpn.week}'),
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (completed) {
                if (completed != null) {
                  _provider.setCpnCompleted(cpn.id, completed);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  CpnEntity? _nextCpn(List<CpnEntity> schedules) {
    for (final schedule in schedules) {
      if (!schedule.completed) return schedule;
    }
    return null;
  }

  Widget _buildHealthTasksButton() {
    return FilledButton.icon(
      onPressed: _openHealthTasks,
      icon: const Icon(Icons.task_alt),
      label: const Text('Voir le suivi de santé'),
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _openHealthTasks() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) => const HealthTasksPage()),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _onAuthChanged(User? user) {
    final uid = user?.uid;
    if (!mounted || uid == _activeUid) return;
    _activeUid = uid;
    _isGuest = uid == null;
    if (widget.repository == null) {
      unawaited(
        _provider.replaceRepository(
          MaternityRepositoryFactory.maternity(uid: uid),
        ),
      );
    }
    if (widget.healthTasksRepository == null) {
      unawaited(
        _healthTasksProvider.replaceRepository(
          MaternityRepositoryFactory.healthTasks(uid: uid),
        ),
      );
    }
    setState(() {});
  }
}
