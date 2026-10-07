import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/notification_service.dart';
import '../../../../core/services/vaccine_reminder_preferences.dart';
import '../../../maternity/presentation/maternity_repository_factory.dart';
import '../../../maternity/domain/repositories/maternity_repository.dart';
import 'user_profile_controller.dart';

typedef MaternityRepositoryCreator =
    MaternityRepository Function(String? uid);

final vaccineReminderPreferencesProvider =
    Provider<VaccineReminderPreferences>(
      (ref) => VaccineReminderPreferences(ref.watch(sharedPreferencesProvider)),
    );

final maternityRepositoryCreatorProvider = Provider<MaternityRepositoryCreator>(
  (ref) => (uid) => MaternityRepositoryFactory.maternity(uid: uid),
);

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(),
);

@immutable
class VaccineReminderSettingsState {
  const VaccineReminderSettingsState({
    required this.enabled,
    this.isUpdating = false,
    this.errorMessage,
  });

  final bool enabled;
  final bool isUpdating;
  final String? errorMessage;

  VaccineReminderSettingsState copyWith({
    bool? enabled,
    bool? isUpdating,
    String? errorMessage,
    bool clearError = false,
  }) {
    return VaccineReminderSettingsState(
      enabled: enabled ?? this.enabled,
      isUpdating: isUpdating ?? this.isUpdating,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class VaccineReminderSettingsController
    extends AsyncNotifier<VaccineReminderSettingsState> {
  @override
  Future<VaccineReminderSettingsState> build() async {
    return VaccineReminderSettingsState(
      enabled: ref.read(vaccineReminderPreferencesProvider).isEnabled,
    );
  }

  Future<void> setEnabled(bool enabled) async {
    final current = state.asData?.value;
    if (current == null || current.isUpdating || current.enabled == enabled) {
      return;
    }

    state = AsyncData(
      current.copyWith(isUpdating: true, clearError: true),
    );
    try {
      if (enabled) {
        await _restoreReminders();
      } else {
        await ref.read(notificationServiceProvider).cancelAllReminders();
      }

      final saved = await ref
          .read(vaccineReminderPreferencesProvider)
          .setEnabled(enabled);
      if (!saved) {
        throw StateError('Impossible d’enregistrer la préférence locale.');
      }
      state = AsyncData(
        VaccineReminderSettingsState(enabled: enabled),
      );
    } catch (error, stackTrace) {
      debugPrint('Échec de mise à jour des rappels vaccinaux: $error\n$stackTrace');
      state = AsyncData(
        VaccineReminderSettingsState(
          enabled: current.enabled,
          errorMessage: _messageFor(error),
        ),
      );
    }
  }

  Future<void> _restoreReminders() async {
    final repository = ref
        .read(maternityRepositoryCreatorProvider)(
          MaternityRepositoryFactory.currentUid,
        );
    final vaccines = await repository.getVaccinationSchedule();
    final now = DateTime.now();
    final pending = [
      for (final vaccine in vaccines)
        if (!vaccine.status && vaccine.reminderAt != null)
          (
            vaccine: vaccine,
            date: DateTime(
              vaccine.reminderAt!.year,
              vaccine.reminderAt!.month,
              vaccine.reminderAt!.day,
              9,
            ),
          ),
    ].where((entry) => entry.date.isAfter(now)).toList(growable: false);

    final ids = <int, String>{};
    for (final entry in pending) {
      final id = NotificationService.notificationIdForVaccine(
        entry.vaccine.id,
      );
      final previousVaccineId = ids[id];
      if (previousVaccineId != null &&
          previousVaccineId != entry.vaccine.id) {
        throw StateError(
          'Collision d’identifiants entre plusieurs rappels vaccinaux.',
        );
      }
      ids[id] = entry.vaccine.id;
    }

    final service = ref.read(notificationServiceProvider);
    try {
      for (final entry in pending) {
        await service.scheduleVaccineReminder(
          vaccineId: entry.vaccine.id,
          title: 'Rappel de vaccination',
          body: 'Vaccin ${entry.vaccine.name} prévu le '
              '${entry.date.day}/${entry.date.month}/${entry.date.year}',
          scheduledDate: entry.date,
          payload: 'vaccine_reminder:${entry.vaccine.id}',
        );
      }
    } catch (error, stackTrace) {
      try {
        await service.cancelAllReminders();
      } catch (cleanupError, cleanupStackTrace) {
        debugPrint(
          'Échec de l’annulation des rappels partiellement restaurés: '
          '$cleanupError\n$cleanupStackTrace',
        );
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  String _messageFor(Object error) {
    if (error is NotificationPermissionDeniedException) {
      return 'Autorisez les notifications dans les paramètres de votre '
          'appareil pour activer les rappels.';
    }
    if (error is ExactAlarmPermissionDeniedException) {
      return 'Autorisez les alarmes exactes dans les paramètres Android '
          'pour activer les rappels à l’heure choisie.';
    }
    return 'Impossible de mettre à jour les rappels. Vérifiez votre '
        'connexion et réessayez.';
  }
}

final vaccineReminderSettingsControllerProvider = AsyncNotifierProvider<
  VaccineReminderSettingsController,
  VaccineReminderSettingsState
>(VaccineReminderSettingsController.new);
