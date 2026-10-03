import 'package:flutter/material.dart';

/// En-tête de l'accueil : logo, ville active et accès au profil.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.city,
    required this.country,
    required this.isSignedIn,
    required this.onProfileTap,
    required this.onSignInTap,
  });

  final String city;
  final String country;
  final bool isSignedIn;
  final VoidCallback onProfileTap;
  final VoidCallback onSignInTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: scheme.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.local_hospital, color: scheme.onPrimary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MediGuide',
                style: text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              Row(
                children: [
                  Icon(Icons.place_outlined, size: 16, color: scheme.primary),
                  const SizedBox(width: 2),
                  Flexible(
                    child: Text(
                      '$city, $country',
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (!isSignedIn)
          // Sur petit écran, une icône : le texte ferait déborder la ligne.
          MediaQuery.sizeOf(context).width < 380
              ? IconButton(
                  onPressed: onSignInTap,
                  tooltip: 'Se connecter',
                  icon: const Icon(Icons.login),
                )
              : TextButton(
                  onPressed: onSignInTap,
                  child: const Text('Se connecter'),
                ),
        IconButton.filledTonal(
          onPressed: onProfileTap,
          tooltip: 'Mon profil',
          icon: const Icon(Icons.person_outline),
        ),
      ],
    );
  }
}
