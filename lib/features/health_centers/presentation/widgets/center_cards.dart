import 'package:flutter/material.dart';

import '../../../../core/utils/geo_distance.dart';
import '../../domain/entities/nearby_center.dart';

const _typeLabels = {
  'hospital': 'Hôpital',
  'clinic': 'Clinique',
  'pharmacy': 'Pharmacie',
};

/// Carte d'une pharmacie de garde : statut, distance, Appeler et Itinéraire.
class GuardPharmacyCard extends StatelessWidget {
  const GuardPharmacyCard({
    super.key,
    required this.item,
    required this.onCall,
    required this.onDirections,
  });

  final NearbyCenter item;
  final VoidCallback onCall;
  final VoidCallback onDirections;

  @override
  Widget build(BuildContext context) {
    final c = item.center;
    final scheme = Theme.of(context).colorScheme;

    return _CardShell(
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _Pill(
              label: 'De garde',
              background: scheme.tertiaryContainer,
              foreground: scheme.onTertiaryContainer,
              dot: true,
            ),
            Text(
              formatDistance(item.distanceKm),
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _Title(c.name),
        if (c.address != null) _Address(c.address!),
        const SizedBox(height: 12),
        _Actions(phone: c.phone, onCall: onCall, onDirections: onDirections),
      ],
    );
  }
}

/// Carte d'un hôpital ou d'une clinique proche.
class NearbyCenterCard extends StatelessWidget {
  const NearbyCenterCard({
    super.key,
    required this.item,
    required this.onOpen,
    required this.onCall,
    required this.onDirections,
  });

  final NearbyCenter item;
  final VoidCallback onOpen;
  final VoidCallback onCall;
  final VoidCallback onDirections;

  @override
  Widget build(BuildContext context) {
    final c = item.center;
    final scheme = Theme.of(context).colorScheme;

    return _CardShell(
      onTap: onOpen,
      children: [
        Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _Pill(
                    label: _typeLabels[c.type] ?? 'Centre de santé',
                    background: scheme.secondaryContainer,
                    foreground: scheme.onSecondaryContainer,
                  ),
                  if (c.is24h)
                    _Pill(
                      label: c.type == 'pharmacy'
                          ? 'Ouvert 24h/24'
                          : 'Urgences 24h/24',
                      background: scheme.errorContainer,
                      foreground: scheme.onErrorContainer,
                      dot: true,
                    ),
                  if (c.isGuard)
                    _Pill(
                      label: 'De garde',
                      background: scheme.tertiaryContainer,
                      foreground: scheme.onTertiaryContainer,
                      dot: true,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _Pill(
              label: formatDistance(item.distanceKm),
              background: scheme.surfaceContainerHighest,
              foreground: scheme.onSurface,
            ),
          ],
        ),
        const SizedBox(height: 8),
        _Title(c.name),
        if (c.address != null) _Address(c.address!),
        if (!c.is24h && c.openingHours != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Horaires : ${c.openingHours}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        const SizedBox(height: 12),
        _Actions(phone: c.phone, onCall: onCall, onDirections: onDirections),
      ],
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.children, this.onTap});

  final List<Widget> children;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(context).textTheme.titleMedium
        ?.copyWith(fontWeight: FontWeight.w800),
  );
}

class _Address extends StatelessWidget {
  const _Address(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.place_outlined, size: 16, color: scheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

/// « Appeler » n'apparaît que si le centre a un numéro (SCHEMA.md).
class _Actions extends StatelessWidget {
  const _Actions({
    required this.phone,
    required this.onCall,
    required this.onDirections,
  });

  final String? phone;
  final VoidCallback onCall;
  final VoidCallback onDirections;

  @override
  Widget build(BuildContext context) {
    final directions = OutlinedButton.icon(
      onPressed: onDirections,
      icon: const Icon(Icons.directions_outlined),
      label: const Text('Itinéraire'),
    );
    if (phone == null) {
      return SizedBox(width: double.infinity, child: directions);
    }
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: onCall,
            icon: const Icon(Icons.call),
            label: const Text('Appeler'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: directions),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.background,
    required this.foreground,
    this.dot = false,
  });

  final String label;
  final Color background;
  final Color foreground;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Icon(Icons.circle, size: 8, color: foreground),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(color: foreground, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
