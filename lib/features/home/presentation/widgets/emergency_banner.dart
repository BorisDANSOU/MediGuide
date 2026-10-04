import 'package:flutter/material.dart';

/// Bandeau rouge d'urgence vitale, toujours en haut de l'accueil.
class EmergencyBanner extends StatelessWidget {
  const EmergencyBanner({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final info = Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: scheme.onError.withValues(alpha: 0.2),
          child: Icon(Icons.emergency, color: scheme.onError),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Urgence vitale ?',
                style: text.titleMedium?.copyWith(
                  color: scheme.onError,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'SAMU, pompiers, police : appel gratuit, sans Internet',
                style: text.bodySmall?.copyWith(color: scheme.onError),
              ),
            ],
          ),
        ),
      ],
    );

    final button = FilledButton.icon(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: scheme.onError,
        foregroundColor: scheme.error,
        // Le thème impose une largeur pleine (Size.fromHeight) : impossible
        // dans une ligne, on rend la largeur libre ici.
        minimumSize: const Size(0, 48),
      ),
      icon: const Icon(Icons.call),
      label: const Text('Numéros d’urgence'),
    );

    return Material(
      color: scheme.error,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        // Bouton à droite sur grand écran, en dessous sur téléphone étroit.
        child: LayoutBuilder(
          builder: (context, constraints) => constraints.maxWidth >= 520
              ? Row(
                  children: [
                    Expanded(child: info),
                    const SizedBox(width: 16),
                    button,
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [info, const SizedBox(height: 12), button],
                ),
        ),
      ),
    );
  }
}
