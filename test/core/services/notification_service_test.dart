import 'package:flutter_test/flutter_test.dart';
import 'package:mediguid/core/services/notification_service.dart';

void main() {
  test('initializes once before scheduling an authorized reminder', () async {
    var initializationCount = 0;
    var permissionRequestCount = 0;
    final scheduledReminders =
        <({int id, String title, String body, DateTime scheduledDate})>[];
    final service = NotificationService(
      initialize: () async => initializationCount++,
      requestPermission: () async {
        permissionRequestCount++;
        return true;
      },
      schedule:
          ({
            required id,
            required title,
            required body,
            required scheduledDate,
          }) async {
            scheduledReminders.add((
              id: id,
              title: title,
              body: body,
              scheduledDate: scheduledDate,
            ));
          },
    );
    final scheduledDate = DateTime.now().add(const Duration(days: 1));

    await service.scheduleVaccineReminder(
      notificationId: 17,
      title: 'Rappel vaccination',
      body: 'Vaccin recommandé',
      scheduledDate: scheduledDate,
    );
    await service.scheduleVaccineReminder(
      notificationId: 18,
      title: 'Rappel consultation',
      body: 'Consultation prénatale',
      scheduledDate: scheduledDate,
    );

    expect(initializationCount, 1);
    expect(permissionRequestCount, 1);
    expect(scheduledReminders, hasLength(2));
    expect(scheduledReminders.first.id, 17);
    expect(scheduledReminders.first.scheduledDate, scheduledDate);
  });

  test('does not schedule when notification permission is denied', () async {
    var scheduleCalled = false;
    final service = NotificationService(
      initialize: () async {},
      requestPermission: () async => false,
      schedule:
          ({
            required id,
            required title,
            required body,
            required scheduledDate,
          }) async {
            scheduleCalled = true;
          },
    );

    await expectLater(
      service.scheduleVaccineReminder(
        notificationId: 4,
        title: 'Rappel',
        body: 'Vaccination',
        scheduledDate: DateTime.now().add(const Duration(days: 1)),
      ),
      throwsA(isA<NotificationPermissionDeniedException>()),
    );
    expect(scheduleCalled, isFalse);
  });

  test('rejects reminders scheduled in the past', () async {
    var scheduleCalled = false;
    final service = NotificationService(
      initialize: () async {},
      requestPermission: () async => true,
      schedule:
          ({
            required id,
            required title,
            required body,
            required scheduledDate,
          }) async {
            scheduleCalled = true;
          },
    );

    await expectLater(
      service.scheduleVaccineReminder(
        notificationId: 4,
        title: 'Rappel',
        body: 'Vaccination',
        scheduledDate: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
      throwsArgumentError,
    );
    expect(scheduleCalled, isFalse);
  });

  test('cancels a reminder by its stable id', () async {
    int? cancelledId;
    final service = NotificationService(
      initialize: () async {},
      cancel: (id) async => cancelledId = id,
    );

    await service.cancelVaccineReminder(notificationId: 23);

    expect(cancelledId, 23);
  });
}
