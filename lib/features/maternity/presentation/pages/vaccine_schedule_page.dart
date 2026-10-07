import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/vaccine_entity.dart';
import '../../domain/repositories/maternity_repository.dart';
import '../controllers/maternity_provider.dart';
import '../maternity_repository_factory.dart';
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
  StreamSubscription<User?>? _authSubscription;
  String? _activeUid;
  bool _isGuest = true;

  @override
  void initState() {
    super.initState();
    _activeUid = MaternityRepositoryFactory.currentUid;
    _isGuest = _activeUid == null;
    final repository = widget.repository ??
        MaternityRepositoryFactory.maternity(uid: _activeUid);
    _provider = MaternityProvider(repository)..loadSchedules();
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
        title: const Text('Calendrier vaccinal'),
        actions: [
          IconButton(
            tooltip: 'Recharger',
            onPressed: _provider.loadSchedules,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
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
                _isGuest
                    ? 'Données locales, enregistrées sur cet appareil uniquement.'
                    : 'Calendrier synchronisé avec votre compte.',
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
                TextButton.icon(
                  onPressed: _provider.loadSchedules,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réessayer'),
                ),
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
                      reminderAt: vaccine.reminderAt,
                      onCompletedChanged: (completed) async {
                        if (!await _provider.setVaccineCompleted(
                          vaccine.id,
                          completed,
                        )) {
                          return;
                        }
                      },
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
                  final saved = await _provider.scheduleVaccineReminder(
                    vaccineId: vaccine.id,
                    vaccineName: vaccine.name,
                    scheduledDate: selectedDate,
                  );
                  if (saved && context.mounted) {
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

  void _onAuthChanged(User? user) {
    final uid = user?.uid;
    if (!mounted || uid == _activeUid) return;
    _activeUid = uid;
    _isGuest = uid == null;
    unawaited(
      _provider.replaceRepository(
        MaternityRepositoryFactory.maternity(uid: uid),
      ),
    );
    setState(() {});
  }
}
