import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/user_profile_controller.dart';
import '../widgets/country_picker_sheet.dart';
import '../widgets/profile_header_card.dart';

/// Écran Profil
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // watch : l'écran se redessine tout seul quand le profil change
    final profileState = ref.watch(userProfileControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      // when() gère les 3 états possibles d'une donnée asynchrone
      body: profileState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Impossible de charger le profil.\n$error')),
        data: (profile) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ProfileHeaderCard(profile: profile),
            const SizedBox(height: 16),

            // Carte "Zone de recherche" : touche pour changer de pays
            Card(
              child: ListTile(
                leading: const Icon(Icons.map_outlined),
                title: const Text('Pays et ville'),
                subtitle: Text('${profile.city}, ${profile.country}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => CountryPickerSheet.show(context),
              ),
            ),
            const SizedBox(height: 24),

            // Déconnexion : à brancher quand l'authentification existera
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Déconnexion disponible après l’intégration '
                      'de l’authentification.',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text('Déconnexion'),
            ),
          ],
        ),
      ),
    );
  }
}
