import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/datasources/maternity_local_ds.dart';
import '../../data/repositories/maternity_repo_impl.dart';
import '../../domain/entities/cpn_entity.dart';
import '../../domain/repositories/maternity_repository.dart';
import '../controllers/maternity_provider.dart';
import '../pages/health_tasks_page.dart';
import '../widgets/maternity_dashboard_widgets.dart';
import '../widgets/vaccine_card.dart';

class MaternityDashboardPage extends StatefulWidget {
  const MaternityDashboardPage({super.key, this.repository});

  final MaternityRepository? repository;

  @override
  State<MaternityDashboardPage> createState() => _MaternityDashboardPageState();
}

class _MaternityDashboardPageState extends State<MaternityDashboardPage> {
  late final MaternityProvider _provider;
  var _showBaby = false;
  var _presenceConfirmed = false;

  @override
  void initState() {
    super.initState();
    final repository =
        widget.repository ??
        const MaternityRepositoryImpl(MaternityLocalDataSource());
    _provider = MaternityProvider(repository)..loadSchedules();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _provider,
          builder: (context, _) => Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MaternityDashboardHeader(
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
                    if (_provider.isLoading) ...[
                      const SizedBox(height: 12),
                      const LinearProgressIndicator(minHeight: 3),
                    ],
                    if (_provider.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      MaternityNotice(message: _provider.errorMessage!),
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
        PregnancySummaryCard(
          cpn: cpn,
          presenceConfirmed: _presenceConfirmed,
          onConfirmPresence: () =>
              setState(() => _presenceConfirmed = !_presenceConfirmed),
          onItinerary: () => _showMessage(
            'L’itinéraire sera disponible après raccordement de la carte.',
          ),
        ),
        const SizedBox(height: 24),
        MaternitySectionHeading(
          title: 'Échéances & Examens Recommandés',
          actionLabel: 'Tout voir',
          onAction: () =>
              _showMessage('Tous les examens recommandés sont affichés.'),
        ),
        const SizedBox(height: 10),
        MaternityExamCard(
          title: '3ème Échographie obstétricale',
          status: 'À planifier',
          details:
              'Recommandée entre 30 et 32 SA (Biométrie et position fœtale)',
          footer: '3 centres équipés à proximité',
          actionLabel: 'Réserver →',
          onAction: () => _showMessage(
            'La réservation des centres n’est pas encore raccordée.',
          ),
        ),
        const SizedBox(height: 8),
        MaternityExamCard(
          title: 'Bilan biologique T2 & Glycémie',
          status: 'Validé',
          details: 'Effectué le 20 Août • Hémoglobine 11.8 g/dL (Normal)',
          footer: 'Consulter compte-rendu',
          actionLabel: 'PDF',
          onAction: () => _showMessage(
            'Aucun compte-rendu n’est disponible dans cette démonstration.',
          ),
          isComplete: true,
        ),
        const SizedBox(height: 8),
        MaternityExamCard(
          title: 'Vaccination antitétanique (VAT)',
          status: 'À venir',
          details: 'Rappel immunitaire pour la mère et le nouveau-né',
          footer: 'Prévu lors de la CPN 3 (Dans 2 semaines max)',
          onAction: () => context.push(AppRoutes.vaccines),
        ),
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
          'Calendrier vaccinal local',
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
              ),
            ),
          ),
      ],
    );
  }

  CpnEntity? _nextCpn(List<CpnEntity> schedules) {
    for (final schedule in schedules) {
      if (schedule.name == 'CPN 3' && !schedule.completed) return schedule;
    }
    for (final schedule in schedules) {
      if (!schedule.completed) return schedule;
    }
    return null;
  }

  String _formatWeek(int week) {
    return 'Semaine $week';
  }

  Widget _buildHealthTasksButton() {
    return FilledButton.icon(
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const HealthTasksPage(),
        ),
      ),
      icon: const Icon(Icons.task_alt),
      label: const Text('Voir le suivi de santé'),
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
