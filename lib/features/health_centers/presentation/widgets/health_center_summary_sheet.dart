
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/health_center_entity.dart';
import 'health_center_marker_style.dart';

/// Fiche rapide d'un centre, ouverte depuis un marqueur de la carte.
/// Elle n'affiche que les informations disponibles pour ce centre.
class HealthCenterSummarySheet extends StatelessWidget {
  const HealthCenterSummarySheet({super.key, required this.center});

  final HealthCenterEntity center;

  /// Ouvre la fiche : HealthCenterSummarySheet.show(context, center)
  static Future<void> show(BuildContext context, HealthCenterEntity center) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => HealthCenterSummarySheet(center: center),
    );
  }

  /// Ouvre un lien dans une autre application (téléphone, cartes).
  /// Sans application capable de l'ouvrir, on prévient l'utilisateur.
  Future<void> _open(BuildContext context, Uri uri) async {
    var opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Impossible d'ouvrir l'application.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = HealthCenterMarkerStyle.forType(center.type);
    final textTheme = Theme.of(context).textTheme;

    // Numéro sans espaces, pour le lien tel:
    final phone = center.phone?.replaceAll(RegExp(r'\s'), '');

    // Itinéraire : lien universel, ouvre l'application de cartes si elle existe
    final directions = Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination': '${center.latitude},${center.longitude}',
    });

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type, ouverture 24h et pharmacie de garde
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(style.icon, color: style.color, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      style.label,
                      style: TextStyle(
                        color: style.color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                if (center.is24h) const _Badge(label: 'Ouvert 24h/24'),
                if (center.isGuard) const _Badge(label: 'Pharmacie de garde'),
              ],
            ),
            const SizedBox(height: 10),

            Text(
              center.name,
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              [center.city, center.country].whereType<String>().join(', '),
              style: textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),

            // Adresse et horaires : seulement s'ils existent
            if (center.address != null)
              _InfoLine(icon: Icons.place_outlined, text: center.address!),
            if (center.openingHours != null && !center.is24h)
              _InfoLine(icon: Icons.schedule, text: center.openingHours!),
            const SizedBox(height: 16),

            // Appeler (si un numéro existe) et Itinéraire
            Row(
              children: [
                if (phone != null && phone.isNotEmpty) ...[
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () =>
                          _open(context, Uri(scheme: 'tel', path: phone)),
                      icon: const Icon(Icons.phone),
                      label: const Text('Appeler'),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _open(context, directions),
                    icon: const Icon(Icons.directions),
                    label: const Text('Itinéraire'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Petite pastille verte (« Ouvert 24h/24 », « Pharmacie de garde »)
class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.mintSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Une ligne d'information avec son icône
class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}