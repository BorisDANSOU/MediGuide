import 'package:flutter/material.dart';

class QuickService {
  const QuickService({
    required this.icon,
    required this.label,
    required this.caption,
    required this.onTap,
    this.isEmergency = false,
  });

  final IconData icon;
  final String label;
  final String caption;
  final VoidCallback onTap;
  final bool isEmergency;
}

/// Grille des raccourcis : 2 colonnes sur petit téléphone, 3 sur téléphone,
/// 6 sur tablette. Les tuiles prennent la hauteur de leur contenu, ce qui
/// évite les débordements quand l'utilisateur agrandit le texte.
class QuickServicesGrid extends StatelessWidget {
  const QuickServicesGrid({super.key, required this.services});

  final List<QuickService> services;

  static const _spacing = 10.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width < 330 ? 2 : (width < 600 ? 3 : 6);
        final tileWidth = (width - _spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: _spacing,
          runSpacing: _spacing,
          children: [
            for (final s in services)
              SizedBox(
                width: tileWidth,
                child: _QuickServiceTile(service: s),
              ),
          ],
        );
      },
    );
  }
}

class _QuickServiceTile extends StatelessWidget {
  const _QuickServiceTile({required this.service});

  final QuickService service;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final accent = service.isEmergency ? scheme.error : scheme.primary;
    final accentSoft = service.isEmergency
        ? scheme.errorContainer
        : scheme.primaryContainer;

    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: service.onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: const BoxConstraints(minHeight: 112),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: accentSoft,
                child: Icon(service.icon, color: accent, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                service.label,
                textAlign: TextAlign.center,
                style: text.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: service.isEmergency ? scheme.error : null,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                service.caption,
                textAlign: TextAlign.center,
                style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
