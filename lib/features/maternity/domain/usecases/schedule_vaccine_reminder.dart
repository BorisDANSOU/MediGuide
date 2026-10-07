import '../../../../core/services/notification_service.dart';

class ScheduleVaccineReminder {
  const ScheduleVaccineReminder(this.notificationService);

  final NotificationService notificationService;

  /// Planifie un rappel de vaccination
  Future<void> call({
    required String vaccineId,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) {
    return notificationService.scheduleVaccineReminder(
      vaccineId: vaccineId,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      payload: payload,
    );
  }

  /// Annule un rappel de vaccination
  Future<void> cancel(String vaccineId) {
    return notificationService.cancelVaccineReminder(vaccineId: vaccineId);
  }

  /// Annule tous les rappels
  Future<void> cancelAll() {
    return notificationService.cancelAllReminders();
  }

  /// Affiche une notification immédiate (pour tests)
  Future<void> showImmediate({
    required String title,
    required String body,
  }) {
    return notificationService.showImmediateNotification(
      title: title,
      body: body,
    );
  }
}
