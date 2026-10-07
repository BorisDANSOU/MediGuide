import '../../../../core/services/notification_service.dart';

class ScheduleVaccineReminder {
  const ScheduleVaccineReminder(this.notificationService);

  final NotificationService notificationService;

  /// Planifie un rappel de vaccination
  Future<void> call({
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) {
    return notificationService.scheduleVaccineReminder(
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      payload: payload,
    );
  }

  /// Annule un rappel de vaccination
  Future<void> cancel(int id) {
    return notificationService.cancelReminder(id);
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
