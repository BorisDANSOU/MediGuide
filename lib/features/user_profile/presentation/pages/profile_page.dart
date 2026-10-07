import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/controllers/auth_providers.dart';
import '../controllers/vaccine_reminder_settings_controller.dart';
import '../controllers/user_profile_controller.dart';
import '../widgets/country_picker_sheet.dart';
import '../widgets/profile_header_card.dart';

/// Écran Profil : zone active, changement de pays et déconnexion.
/// ConsumerWidget : un widget qui peut observer des providers Riverpod.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(userProfileControllerProvider);
    final reminderSettings = ref.watch(
      vaccineReminderSettingsControllerProvider,
    );
    final user = ref.watch(authSessionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: profileState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text('Impossible de charger le profil.\n$error'),
              ),
              data: (profile) => ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ProfileHeaderCard(profile: profile, user: user),
                  const SizedBox(height: 16),
                  reminderSettings.when(
                    loading: () => const Card(
                      child: ListTile(
                        leading: Icon(Icons.notifications_active_outlined),
                        title: Text('Rappels de vaccination'),
                        trailing: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                    error: (error, _) => const Card(
                      child: ListTile(
                        leading: Icon(Icons.notifications_off_outlined),
                        title: Text('Rappels de vaccination'),
                        subtitle: Text(
                          'Impossible de charger les préférences locales.',
                        ),
                      ),
                    ),
                    data: (settings) => Card(
                      child: Column(
                        children: [
                          SwitchListTile(
                            key: const ValueKey('vaccine-reminders-switch'),
                            secondary: const Icon(
                              Icons.notifications_active_outlined,
                            ),
                            title: const Text('Rappels de vaccination'),
                            subtitle: const Text(
                              'Notifications locales à 09 h 00, '
                              'selon les autorisations de cet appareil.',
                            ),
                            value: settings.enabled,
                            onChanged: settings.isUpdating
                                ? null
                                : (enabled) => unawaited(
                                    ref
                                        .read(
                                          vaccineReminderSettingsControllerProvider
                                              .notifier,
                                        )
                                        .setEnabled(enabled),
                                  ),
                          ),
                          if (settings.errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                              child: Text(
                                settings.errorMessage!,
                                key: const ValueKey('vaccine-reminders-error'),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.map_outlined),
                      title: const Text('Zone de recherche'),
                      subtitle: Text(
                        '${profile.city}, ${profile.country}\n'
                        'Enregistrée sur cet appareil, indépendamment du pays '
                        'du compte.',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => CountryPickerSheet.show(context),
                    ),
                  ),
                  if (user != null) ...[
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: () => _confirmSignOut(context, ref),
                      icon: const Icon(Icons.logout),
                      label: const Text('Déconnexion'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(authSessionProvider.notifier).signOut();
      if (context.mounted) context.go(AppRoutes.auth);
    } on AuthFailure catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } catch (error, stackTrace) {
      debugPrint('Échec de la déconnexion: $error\n$stackTrace');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible de vous déconnecter. Réessayez.'),
          ),
        );
      }
    }
  }
}
