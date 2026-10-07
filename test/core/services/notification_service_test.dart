import 'package:flutter_test/flutter_test.dart';
import 'package:mediguid/core/services/notification_service.dart';

void main() {
  test('initializes once before scheduling an authorized reminder', () async {
    var initializationCount = 0;
    var permissionRequestCount = 0;
    var exactAlarmCheckCount = 0;
    final scheduledReminders =
        <({int id, String title, String body, DateTime scheduledDate})>[];
    final service = NotificationService(
      initialize: () async => initializationCount++,
      requestPermission: () async {
        permissionRequestCount++;
        return true;
      },
      canScheduleExactAlarms: () async {
        exactAlarmCheckCount++;
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
      vaccineId: 'bcg',
      title: 'Rappel vaccination',
      body: 'Vaccin recommandé',
      scheduledDate: scheduledDate,
    );
    await service.scheduleVaccineReminder(
      vaccineId: 'polio',
      title: 'Rappel consultation',
      body: 'Consultation prénatale',
      scheduledDate: scheduledDate,
    );

    expect(initializationCount, 1);
    expect(permissionRequestCount, 2);
    expect(exactAlarmCheckCount, 2);
    expect(scheduledReminders, hasLength(2));
    expect(
      scheduledReminders.first.id,
      NotificationService.notificationIdForVaccine('bcg'),
    );
    expect(scheduledReminders.first.scheduledDate, scheduledDate);
  });

  test('does not schedule when notification permission is denied', () async {
    var scheduleCalled = false;
    final service = NotificationService(
      initialize: () async {},
      requestPermission: () async => false,
      canScheduleExactAlarms: () async => true,
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
        vaccineId: 'bcg',
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
      canScheduleExactAlarms: () async => true,
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
        vaccineId: 'bcg',
        title: 'Rappel',
        body: 'Vaccination',
        scheduledDate: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
      throwsArgumentError,
    );
    expect(scheduleCalled, isFalse);
  });

  test('cancels a vaccine reminder by its stable id', () async {
    int? cancelledId;
    final service = NotificationService(
      initialize: () async {},
      cancel: (id) async => cancelledId = id,
    );

    await service.cancelVaccineReminder(vaccineId: 'bcg');

    expect(cancelledId, NotificationService.notificationIdForVaccine('bcg'));
    expect(
      NotificationService.notificationIdForVaccine('bcg'),
      NotificationService.notificationIdForVaccine('bcg'),
    );
  });

  test(
    'requests exact-alarm access and refuses scheduling if denied',
    () async {
      var permissionRequested = false;
      var scheduleCalled = false;
      final service = NotificationService(
        initialize: () async {},
        requestPermission: () async => true,
        canScheduleExactAlarms: () async => false,
        requestExactAlarmsPermission: () async {
          permissionRequested = true;
          return false;
        },
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
          vaccineId: 'bcg',
          title: 'Rappel',
          body: 'Vaccination',
          scheduledDate: DateTime.now().add(const Duration(days: 1)),
        ),
        throwsA(isA<ExactAlarmPermissionDeniedException>()),
      );
      expect(permissionRequested, isTrue);
      expect(scheduleCalled, isFalse);
    },
  );

  test('rechecks exact-alarm access after the user grants it', () async {
    var exactAlarmChecks = 0;
    var permissionRequests = 0;
    var scheduleCalled = false;
    final service = NotificationService(
      initialize: () async {},
      requestPermission: () async => true,
      canScheduleExactAlarms: () async => ++exactAlarmChecks > 1,
      requestExactAlarmsPermission: () async {
        permissionRequests++;
        return true;
      },
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

    await service.scheduleVaccineReminder(
      vaccineId: 'bcg',
      title: 'Rappel',
      body: 'Vaccination',
      scheduledDate: DateTime.now().add(const Duration(days: 1)),
    );

    expect(exactAlarmChecks, 2);
    expect(permissionRequests, 1);
    expect(scheduleCalled, isTrue);
  });

  test(
    'handles only valid vaccine notification payloads once on cold start',
    () async {
      var navigationCount = 0;
      final service = NotificationService(
        initialize: () async {},
        readLaunchPayload: () async => 'vaccine_reminder:bcg',
      )..setNotificationTapHandler((_) => navigationCount++);

      await service.initialize();
      await service.handleInitialNotificationTap();
      await service.handleInitialNotificationTap();
      service.handleNotificationTap('unknown:bcg');

      expect(navigationCount, 1);
    },
  );
}
