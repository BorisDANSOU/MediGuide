import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediguid/core/services/notification_service.dart';
import 'package:mediguid/features/maternity/domain/entities/cpn_entity.dart';
import 'package:mediguid/features/maternity/domain/entities/vaccine_entity.dart';
import 'package:mediguid/features/maternity/domain/repositories/maternity_repository.dart';
import 'package:mediguid/features/user_profile/presentation/controllers/user_profile_controller.dart';
import 'package:mediguid/features/user_profile/presentation/controllers/vaccine_reminder_settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('restores future incomplete reminders when enabled', () async {
    SharedPreferences.setMockInitialValues({'vaccine_reminders_enabled': false});
    final preferences = await SharedPreferences.getInstance();
    final repository = _FakeMaternityRepository([
      VaccineEntity(
        id: 'bcg',
        name: 'BCG',
        recommendedMonth: 0,
        status: false,
        reminderAt: DateTime.now().add(const Duration(days: 2)),
      ),
      VaccineEntity(
        id: 'completed',
        name: 'Vaccin terminé',
        recommendedMonth: 1,
        status: true,
        reminderAt: DateTime.now().add(const Duration(days: 3)),
      ),
      VaccineEntity(
        id: 'past',
        name: 'Vaccin passé',
        recommendedMonth: 2,
        status: false,
        reminderAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ]);
    final scheduledIds = <int>[];
    final scheduledDates = <DateTime>[];
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
            scheduledIds.add(id);
            scheduledDates.add(scheduledDate);
          },
    );
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        maternityRepositoryCreatorProvider.overrideWithValue(
          (_) => repository,
        ),
        notificationServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);

    await container.read(vaccineReminderSettingsControllerProvider.future);
    await container
        .read(vaccineReminderSettingsControllerProvider.notifier)
        .setEnabled(true);

    expect(preferences.getBool('vaccine_reminders_enabled'), isTrue);
    expect(scheduledIds, [
      NotificationService.notificationIdForVaccine('bcg'),
    ]);
    expect(scheduledDates.single.hour, 9);
    expect(scheduledDates.single.minute, 0);
    expect(
      container
          .read(vaccineReminderSettingsControllerProvider)
          .requireValue
          .errorMessage,
      isNull,
    );
  });

  test('keeps reminders disabled when exact-alarm access is refused', () async {
    SharedPreferences.setMockInitialValues({'vaccine_reminders_enabled': false});
    final preferences = await SharedPreferences.getInstance();
    final repository = _FakeMaternityRepository([
      VaccineEntity(
        id: 'bcg',
        name: 'BCG',
        recommendedMonth: 0,
        status: false,
        reminderAt: DateTime.now().add(const Duration(days: 2)),
      ),
    ]);
    final service = NotificationService(
      initialize: () async {},
      requestPermission: () async => true,
      canScheduleExactAlarms: () async => false,
      requestExactAlarmsPermission: () async => false,
      cancelAll: () async {},
    );
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        maternityRepositoryCreatorProvider.overrideWithValue(
          (_) => repository,
        ),
        notificationServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);

    await container.read(vaccineReminderSettingsControllerProvider.future);
    await container
        .read(vaccineReminderSettingsControllerProvider.notifier)
        .setEnabled(true);

    final state = container
        .read(vaccineReminderSettingsControllerProvider)
        .requireValue;
    expect(state.enabled, isFalse);
    expect(state.errorMessage, contains('alarmes exactes'));
    expect(preferences.getBool('vaccine_reminders_enabled'), isFalse);
  });
}

class _FakeMaternityRepository implements MaternityRepository {
  const _FakeMaternityRepository(this.vaccines);

  final List<VaccineEntity> vaccines;

  @override
  Future<List<VaccineEntity>> getVaccinationSchedule() async => vaccines;

  @override
  Future<List<CpnEntity>> getCpnSchedule() async => const [];

  @override
  Future<void> setVaccineCompleted(String vaccineId, bool completed) async {}

  @override
  Future<void> setCpnCompleted(String cpnId, bool completed) async {}

  @override
  Future<void> setVaccineReminder(
    String vaccineId,
    DateTime? reminderAt,
  ) async {}
}
