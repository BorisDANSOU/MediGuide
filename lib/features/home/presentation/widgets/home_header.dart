import 'package:flutter/material.dart';

/// En-tête de l'accueil : logo, ville active et accès au profil.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.city,
    required this.country,
    required this.onProfileTap,
  });

  final String city;
  final String country;
  final VoidCallback onProfileTap;

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
        IconButton.filledTonal(
          onPressed: onProfileTap,
          tooltip: 'Mon profil',
          icon: const Icon(Icons.person_outline),
        ),
      ],
    );
  }
}
