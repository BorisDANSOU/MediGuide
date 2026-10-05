import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/datasources/maternity_local_ds.dart';
import '../../data/repositories/maternity_repo_impl.dart';
import '../../domain/entities/vaccine_entity.dart';
import '../../domain/repositories/maternity_repository.dart';
import '../controllers/maternity_provider.dart';
import '../widgets/maternity_dashboard_widgets.dart';
import '../widgets/vaccine_card.dart';

class VaccineSchedulePage extends StatefulWidget {
  const VaccineSchedulePage({super.key, this.repository});

  final MaternityRepository? repository;

  @override
  State<VaccineSchedulePage> createState() => _VaccineSchedulePageState();
}

class _VaccineSchedulePageState extends State<VaccineSchedulePage> {
  late final MaternityProvider _provider;

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
      appBar: AppBar(title: const Text('Calendrier vaccinal')),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _provider,
          builder: (context, _) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Vaccins recommandés',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'Calendrier chargé depuis les données locales.',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: AppColors.textSecondary),
              ),
              if (_provider.isLoading) ...[
                const SizedBox(height: 16),
                const LinearProgressIndicator(minHeight: 3),
              ],
              if (_provider.errorMessage != null) ...[
                const SizedBox(height: 12),
                MaternityNotice(message: _provider.errorMessage!),
              ],
              const SizedBox(height: 12),
              if (_provider.vaccines.isEmpty && !_provider.isLoading)
                const MaternityNotice(
                  message: 'Aucun vaccin prévu pour le moment.',
                )
              else
                ..._provider.vaccines.map(
                  (vaccine) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: VaccineCard(
                      name: vaccine.name,
                      month: vaccine.recommendedMonth,
                      completed: vaccine.status,
                      description: vaccine.description,
                      onScheduleReminder: !vaccine.status
                          ? () => _showScheduleDialog(vaccine)
                          : null,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showScheduleDialog(VaccineEntity vaccine) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Planifier un rappel'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vaccin: ${vaccine.name}'),
            const SizedBox(height: 8),
            const Text('Choisissez la date du rappel:'),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 7)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (selectedDate != null && context.mounted) {
                  Navigator.of(context).pop();
                  await _provider.scheduleVaccineReminder(
                    vaccineName: vaccine.name,
                    scheduledDate: selectedDate,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Rappel planifié pour le ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                        ),
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.calendar_today),
              label: const Text('Sélectionner une date'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }
}
