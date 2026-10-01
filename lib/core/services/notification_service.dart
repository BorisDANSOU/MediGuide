class NotificationService {
  const NotificationService();

  Future<void> scheduleVaccineReminder({
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // Placeholder for local reminder scheduling.
    // Later this can integrate flutter_local_notifications.
    await Future<void>.value();
  }
}
