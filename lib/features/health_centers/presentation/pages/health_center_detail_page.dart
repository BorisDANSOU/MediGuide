import 'package:flutter/material.dart';

import '../../../../core/utils/external_actions.dart';
import '../../../../core/utils/distance_formatter.dart';
import '../../../../core/widgets/responsive_cards.dart';
import '../../domain/entities/health_center_entity.dart';

const _typeLabels = {
  'hospital': 'Hôpital',
  'clinic': 'Clinique',
  'pharmacy': 'Pharmacie',
};

/// Écran 06 : fiche structure détaillée (KABORE).
class HealthCenterDetailPage extends StatelessWidget {
  const HealthCenterDetailPage({
    super.key,
    required this.center,
    this.distanceKm,
  });

  final HealthCenterEntity center;
  final double? distanceKm;

  @override
  Widget build(BuildContext context) {
    final c = center;

    return Scaffold(
      appBar: AppBar(title: const Text('Fiche établissement')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 720;
            final padding = constraints.maxWidth >= 600 ? 24.0 : 16.0;

            final header = _Header(center: c, distanceKm: distanceKm);
            final actions = _ActionBlocks(center: c);
            final info = _PracticalInfo(center: c);

            return ListView(
              padding: EdgeInsets.all(padding),
              children: [
                MaxWidth(
                  // Sur tablette : identité et actions à gauche, infos à droite.
                  child: wide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  header,
                                  const SizedBox(height: 16),
                                  actions,
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(child: info),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            header,
                            const SizedBox(height: 16),
                            actions,
                            const SizedBox(height: 16),
                            info,
                          ],
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.center, this.distanceKm});

  final HealthCenterEntity center;
  final double? distanceKm;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final c = center;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _Tag(
              label: _typeLabels[c.type] ?? 'Centre de santé',
              background: scheme.secondaryContainer,
              foreground: scheme.onSecondaryContainer,
            ),
            if (c.is24h)
              _Tag(
                label: c.type == 'pharmacy'
                    ? 'Ouvert 24h/24'
                    : 'Urgences 24h/24',
                background: scheme.errorContainer,
                foreground: scheme.onErrorContainer,
              ),
            if (c.isGuard)
              _Tag(
                label: 'De garde',
                background: scheme.tertiaryContainer,
                foreground: scheme.onTertiaryContainer,
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          c.name,
          style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        if (c.city != null || distanceKm != null) ...[
          const SizedBox(height: 4),
          Text(
            [
              if (c.city != null) '${c.city}, ${c.country ?? ''}'.trim(),
              if (distanceKm != null) 'à ${formatDistance(distanceKm!)}',
            ].join(' · '),
            style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}

/// Deux grands blocs d'action, comme sur la maquette : Appeler et Itinéraire.
class _ActionBlocks extends StatelessWidget {
  const _ActionBlocks({required this.center});

  final HealthCenterEntity center;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final c = center;

    final call = c.phone == null
        ? null
        : _ActionBlock(
            overline: 'Accueil',
            title: 'Appeler',
            subtitle: c.phone!,
            icon: Icons.call,
            background: scheme.primary,
            foreground: scheme.onPrimary,
            onTap: () => callPhoneNumber(context, c.phone!),
          );
    final directions = _ActionBlock(
      overline: 'Navigation',
      title: 'Itinéraire',
      subtitle: 'Ouvrir dans les cartes',
      icon: Icons.directions,
      background: scheme.secondary,
      foreground: scheme.onSecondary,
      onTap: () => openDirections(
        context,
        latitude: c.latitude,
        longitude: c.longitude,
        label: c.name,
      ),
    );

    return ResponsiveCards(twoColumnsFrom: 420, children: [?call, directions]);
  }
}

class _ActionBlock extends StatelessWidget {
  const _ActionBlock({
    required this.overline,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final String overline;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      overline.toUpperCase(),
                      style: text.labelSmall?.copyWith(
                        color: foreground,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      title,
                      style: text.titleLarge?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: text.bodySmall?.copyWith(color: foreground),
                    ),
                  ],
                ),
              ),
              Icon(icon, color: foreground),
            ],
          ),
        ),
      ),
    );
  }
}

class _PracticalInfo extends StatelessWidget {
  const _PracticalInfo({required this.center});

  final HealthCenterEntity center;

  @override
  Widget build(BuildContext context) {
    final c = center;
    final hours = c.is24h
        ? '24h/24, 7j/7'
        : (c.openingHours ?? 'Horaires non renseignés');

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                'Informations pratiques',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.place_outlined),
              title: const Text('Adresse'),
              subtitle: Text(c.address ?? 'Adresse non renseignée'),
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Horaires'),
              subtitle: Text(hours),
            ),
            ListTile(
              leading: const Icon(Icons.phone_outlined),
              title: const Text('Téléphone'),
              subtitle: Text(c.phone ?? 'Numéro non renseigné'),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(
                'Informations issues d’OpenStreetMap : elles peuvent être '
                'incomplètes. Vérifiez par téléphone avant de vous déplacer.',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      label,
      style: Theme.of(context).textTheme.labelMedium
          ?.copyWith(color: foreground, fontWeight: FontWeight.w700),
    ),
  );
}
