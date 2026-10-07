import 'package:flutter/foundation.dart';

import '../../../../core/services/notification_service.dart';
import '../../../../core/services/vaccine_reminder_preferences.dart';
import '../../domain/entities/cpn_entity.dart';
import '../../domain/entities/vaccine_entity.dart';
import '../../domain/repositories/maternity_repository.dart';
import '../../domain/usecases/schedule_vaccine_reminder.dart';

class MaternityProvider extends ChangeNotifier {
  MaternityProvider(
    this.repository, {
    ScheduleVaccineReminder? scheduleReminder,
    NotificationService? notificationService,
    this.reminderPreferences,
  }) : _scheduleReminder =
           scheduleReminder ??
           ScheduleVaccineReminder(
             notificationService ?? NotificationService(),
           );

  MaternityRepository repository;
  final ScheduleVaccineReminder _scheduleReminder;
  final VaccineReminderPreferences? reminderPreferences;

  List<VaccineEntity> _vaccines = const [];
  List<CpnEntity> _cpnSchedules = const [];
  bool _isLoading = false;
  String? _errorMessage;

  List<VaccineEntity> get vaccines => _vaccines;
  List<CpnEntity> get cpnSchedules => _cpnSchedules;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int _loadGeneration = 0;

  void reportError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> replaceRepository(MaternityRepository value) async {
    if (identical(repository, value)) return;
    repository = value;
    _vaccines = const [];
    _cpnSchedules = const [];
    _errorMessage = null;
    notifyListeners();
    await loadSchedules();
  }

  Future<void> loadSchedules() async {
    final generation = ++_loadGeneration;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final vaccines = await repository.getVaccinationSchedule();
      final cpnSchedules = await repository.getCpnSchedule();
      if (generation != _loadGeneration) return;
      _vaccines = vaccines;
      _cpnSchedules = cpnSchedules;
    } catch (_) {
      if (generation == _loadGeneration) {
        _errorMessage = 'Impossible de charger les données maternité.';
      }
    } finally {
      if (generation == _loadGeneration) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> setVaccineCompleted(String vaccineId, bool completed) async {
    try {
      await repository.setVaccineCompleted(vaccineId, completed);
      _vaccines = [
        for (final vaccine in _vaccines)
          if (vaccine.id == vaccineId)
            VaccineEntity(
              id: vaccine.id,
              name: vaccine.name,
              recommendedMonth: vaccine.recommendedMonth,
              status: completed,
              description: vaccine.description,
              reminderAt: vaccine.reminderAt,
            )
          else
            vaccine,
      ];
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (_) {
      _errorMessage = 'Impossible d’enregistrer la progression du vaccin.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> setCpnCompleted(String cpnId, bool completed) async {
    try {
      await repository.setCpnCompleted(cpnId, completed);
      _cpnSchedules = [
        for (final cpn in _cpnSchedules)
          if (cpn.id == cpnId)
            CpnEntity(
              id: cpn.id,
              name: cpn.name,
              week: cpn.week,
              completed: completed,
              description: cpn.description,
            )
          else
            cpn,
      ];
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (_) {
      _errorMessage = 'Impossible d’enregistrer la progression de la CPN.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> scheduleVaccineReminder({
    required String vaccineId,
    required String vaccineName,
    required DateTime scheduledDate,
  }) async {
    final reminderAt = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      9,
    );
    if (!reminderAt.isAfter(DateTime.now())) {
      _errorMessage =
          'Choisissez une date dont le rappel à 09 h 00 n’est pas déjà passé.';
      notifyListeners();
      return false;
    }

    try {
      await repository.setVaccineReminder(vaccineId, reminderAt);
      _vaccines = [
        for (final vaccine in _vaccines)
          if (vaccine.id == vaccineId)
            VaccineEntity(
              id: vaccine.id,
              name: vaccine.name,
              recommendedMonth: vaccine.recommendedMonth,
              status: vaccine.status,
              description: vaccine.description,
              reminderAt: reminderAt,
            )
          else
            vaccine,
      ];
    } catch (_) {
      _errorMessage = 'Impossible de synchroniser la date de rappel.';
      notifyListeners();
      return false;
    }

    if (reminderPreferences?.isEnabled == false) {
      _errorMessage =
          'La date est enregistrée, mais les notifications sont désactivées '
          'dans votre profil.';
      notifyListeners();
      return false;
    }

    try {
      await _scheduleReminder(
        vaccineId: vaccineId,
        title: 'Rappel de vaccination',
        body: 'Vaccin $vaccineName prévu le ${_formatDate(reminderAt)}',
        scheduledDate: reminderAt,
        payload: 'vaccine_reminder:$vaccineId',
      );
      _errorMessage = null;
      notifyListeners();
      return true;
    } on NotificationPermissionDeniedException {
      _errorMessage =
          'La date est enregistrée, mais la permission de notifications '
          'est refusée sur cet appareil.';
      notifyListeners();
      return false;
    } on ExactAlarmPermissionDeniedException {
      _errorMessage =
          'La date est enregistrée, mais l’accès aux alarmes exactes est '
          'refusé dans les paramètres Android.';
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage =
          'La date est enregistrée, mais la notification locale '
          'n’a pas pu être programmée sur cet appareil.';
      notifyListeners();
      return false;
    }
  }

  /// Annule tous les rappels
  Future<void> cancelAllReminders() async {
    try {
      await _scheduleReminder.cancelAll();
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'annulation des rappels: $e';
      notifyListeners();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
