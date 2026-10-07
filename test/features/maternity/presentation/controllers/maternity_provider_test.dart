import 'package:flutter_test/flutter_test.dart';
import 'package:mediguid/core/services/notification_service.dart';
import 'package:mediguid/core/services/vaccine_reminder_preferences.dart';
import 'package:mediguid/features/maternity/domain/usecases/schedule_vaccine_reminder.dart';
import 'package:mediguid/features/maternity/domain/entities/cpn_entity.dart';
import 'package:mediguid/features/maternity/domain/entities/vaccine_entity.dart';
import 'package:mediguid/features/maternity/domain/repositories/maternity_repository.dart';
import 'package:mediguid/features/maternity/presentation/controllers/maternity_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('loads CPN and vaccine schedules from the repository', () async {
    final provider = MaternityProvider(
      _FakeMaternityRepository(
        vaccines: const [
          VaccineEntity(
            id: 'bcg',
            name: 'BCG',
            recommendedMonth: 0,
            status: false,
          ),
        ],
        cpnSchedules: const [
          CpnEntity(id: 'cpn1', name: 'CPN 1', week: 12, completed: false),
        ],
      ),
    );

    await provider.loadSchedules();

    expect(provider.vaccines, hasLength(1));
    expect(provider.vaccines.single.name, 'BCG');
    expect(provider.cpnSchedules, hasLength(1));
    expect(provider.cpnSchedules.single.name, 'CPN 1');
    expect(provider.isLoading, isFalse);
    expect(provider.errorMessage, isNull);
    provider.dispose();
  });

  test('exposes a generic error when schedule loading fails', () async {
    final provider = MaternityProvider(
      _FakeMaternityRepository(error: Exception('private detail')),
    );

    await provider.loadSchedules();

    expect(
      provider.errorMessage,
      'Impossible de charger les données maternité.',
    );
    expect(provider.errorMessage, isNot(contains('private detail')));
    expect(provider.isLoading, isFalse);
    provider.dispose();
  });

  test('persists vaccine and CPN completion before updating state', () async {
    final repository = _FakeMaternityRepository(
      vaccines: const [
        VaccineEntity(
          id: 'bcg',
          name: 'BCG',
          recommendedMonth: 0,
          status: false,
        ),
      ],
      cpnSchedules: const [
        CpnEntity(id: 'cpn1', name: 'CPN 1', week: 12, completed: false),
      ],
    );
    final provider = MaternityProvider(repository);
    await provider.loadSchedules();

    expect(await provider.setVaccineCompleted('bcg', true), isTrue);
    expect(await provider.setCpnCompleted('cpn1', true), isTrue);
    expect(provider.vaccines.single.status, isTrue);
    expect(provider.cpnSchedules.single.completed, isTrue);
    expect(repository.writes, ['vaccine:bcg:true', 'cpn:cpn1:true']);
    provider.dispose();
  });

  test(
    'does not report progress as saved when repository write fails',
    () async {
      final repository = _FakeMaternityRepository(
        writeError: StateError('offline'),
      );
      final provider = MaternityProvider(repository);

      expect(await provider.setVaccineCompleted('bcg', true), isFalse);
      expect(
        provider.errorMessage,
        'Impossible d’enregistrer la progression du vaccin.',
      );
      expect(provider.vaccines, isEmpty);
      provider.dispose();
    },
  );

  test('saves a date at 09:00 without scheduling when reminders are disabled',
      () async {
    SharedPreferences.setMockInitialValues({
      VaccineReminderPreferences.enabledKey: false,
    });
    final preferences = VaccineReminderPreferences(
      await SharedPreferences.getInstance(),
    );
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
    final repository = _FakeMaternityRepository();
    final provider = MaternityProvider(
      repository,
      scheduleReminder: ScheduleVaccineReminder(service),
      reminderPreferences: preferences,
    );
    final selectedDate = DateTime.now().add(const Duration(days: 2));

    expect(
      await provider.scheduleVaccineReminder(
        vaccineId: 'bcg',
        vaccineName: 'BCG',
        scheduledDate: selectedDate,
      ),
      isFalse,
    );

    final savedDate = repository.savedReminders.single;
    expect(savedDate.hour, 9);
    expect(savedDate.minute, 0);
    expect(scheduleCalled, isFalse);
    expect(provider.errorMessage, contains('notifications sont désactivées'));
    provider.dispose();
  });

  test('rejects a reminder date whose 09:00 time has passed', () async {
    final repository = _FakeMaternityRepository();
    final provider = MaternityProvider(repository);
    final today = DateTime.now();

    if (today.hour >= 9) {
      expect(
        await provider.scheduleVaccineReminder(
          vaccineId: 'bcg',
          vaccineName: 'BCG',
          scheduledDate: today,
        ),
        isFalse,
      );
      expect(repository.savedReminders, isEmpty);
      expect(provider.errorMessage, contains('09 h 00'));
    }
    provider.dispose();
  });

  test('clears previous account schedules when repository changes', () async {
    final first = _FakeMaternityRepository(
      vaccines: const [
        VaccineEntity(
          id: 'private-a',
          name: 'Compte A',
          recommendedMonth: 0,
          status: true,
        ),
      ],
    );
    final second = _FakeMaternityRepository(
      vaccines: const [
        VaccineEntity(
          id: 'private-b',
          name: 'Compte B',
          recommendedMonth: 1,
          status: false,
        ),
      ],
    );
    final provider = MaternityProvider(first);
    await provider.loadSchedules();

    await provider.replaceRepository(second);

    expect(provider.vaccines.map((vaccine) => vaccine.id), ['private-b']);
    provider.dispose();
  });
}

class _FakeMaternityRepository implements MaternityRepository {
  _FakeMaternityRepository({
    this.vaccines = const [],
    this.cpnSchedules = const [],
    this.error,
    this.writeError,
  });

  final List<VaccineEntity> vaccines;
  final List<CpnEntity> cpnSchedules;
  final Object? error;
  final Object? writeError;
  final writes = <String>[];
  final savedReminders = <DateTime>[];

  @override
  Future<List<VaccineEntity>> getVaccinationSchedule() async {
    if (error != null) throw error!;
    return vaccines;
  }

  @override
  Future<List<CpnEntity>> getCpnSchedule() async {
    if (error != null) throw error!;
    return cpnSchedules;
  }

  @override
  Future<void> setVaccineCompleted(String vaccineId, bool completed) async {
    if (writeError != null) throw writeError!;
    writes.add('vaccine:$vaccineId:$completed');
  }

  @override
  Future<void> setCpnCompleted(String cpnId, bool completed) async {
    if (writeError != null) throw writeError!;
    writes.add('cpn:$cpnId:$completed');
  }

  @override
  Future<void> setVaccineReminder(
    String vaccineId,
    DateTime? reminderAt,
  ) async {
    if (writeError != null) throw writeError!;
    writes.add('reminder:$vaccineId:$reminderAt');
    if (reminderAt != null) savedReminders.add(reminderAt);
  }
}
