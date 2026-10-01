import '../../../../core/services/notification_service.dart';

class ScheduleVaccineReminder {
  const ScheduleVaccineReminder(this.notificationService);

  final NotificationService notificationService;

  Future<void> call({
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) {
    return notificationService.scheduleVaccineReminder(
      title: title,
      body: body,
      scheduledDate: scheduledDate,
    );
  }
}
