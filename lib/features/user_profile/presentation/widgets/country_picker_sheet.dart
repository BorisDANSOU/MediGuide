import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/supported_locations.dart';
import '../controllers/user_profile_controller.dart';

/// Feuille qui monte du bas de l'écran pour choisir un pays.
/// Elle se lit et s'ouvre avec CountryPickerSheet.show(context).
class CountryPickerSheet extends ConsumerWidget {
  const CountryPickerSheet({super.key});

  /// Ouvre la feuille. "static"
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      builder: (_) => const CountryPickerSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    // Pays actuellement choisi (null tant que le profil se charge)
    final currentCountry = ref
        .watch(userProfileControllerProvider)
        .value
        ?.country;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min, // la feuille s'adapte à son contenu
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Choisir un pays',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          // Une ligne par lieu supporté
          for (final location in SupportedLocations.all)
            ListTile(
              leading: const Icon(Icons.public),
              title: Text(location.country),
              subtitle: Text(location.city),
              // Coche verte sur le pays actif
              trailing: location.country == currentCountry
                  ? Icon(Icons.check_circle, color: scheme.primary)
                  : null,
              onTap: () {
                final controller = ref.read(
                  userProfileControllerProvider.notifier,
                );
                Navigator.of(context).pop();
                controller.selectCountry(location.country);
              },
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
