import 'package:flutter/foundation.dart';

import '../../../../core/services/notification_service.dart';
import '../../domain/entities/cpn_entity.dart';
import '../../domain/entities/vaccine_entity.dart';
import '../../domain/repositories/maternity_repository.dart';
import '../../domain/usecases/schedule_vaccine_reminder.dart';

class MaternityProvider extends ChangeNotifier {
  MaternityProvider(
    this.repository, {
    ScheduleVaccineReminder? scheduleReminder,
  }) : _scheduleReminder = scheduleReminder ?? ScheduleVaccineReminder(
          NotificationService(),
        );

  final MaternityRepository repository;
  final ScheduleVaccineReminder _scheduleReminder;

  List<VaccineEntity> _vaccines = const [];
  List<CpnEntity> _cpnSchedules = const [];
  bool _isLoading = false;
  String? _errorMessage;

  List<VaccineEntity> get vaccines => _vaccines;
  List<CpnEntity> get cpnSchedules => _cpnSchedules;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadSchedules() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final vaccines = await repository.getVaccinationSchedule();
      final cpnSchedules = await repository.getCpnSchedule();
      _vaccines = vaccines;
      _cpnSchedules = cpnSchedules;
    } catch (_) {
      _errorMessage = 'Impossible de charger les données maternité.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Planifie un rappel pour un vaccin
  Future<void> scheduleVaccineReminder({
    required String vaccineName,
    required DateTime scheduledDate,
  }) async {
    try {
      await _scheduleReminder(
        title: 'Rappel de vaccination',
        body: 'Vaccin $vaccineName prévu pour le ${_formatDate(scheduledDate)}',
        scheduledDate: scheduledDate,
        payload: vaccineName,
      );
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors de la planification du rappel: $e';
      notifyListeners();
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
