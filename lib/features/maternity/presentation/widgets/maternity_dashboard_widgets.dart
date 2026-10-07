import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/cpn_entity.dart';

class MaternityDashboardHeader extends StatelessWidget {
  const MaternityDashboardHeader({
    super.key,
    this.dossierName,
    required this.onSettings,
    required this.onProfile,
  });
  final String? dossierName;
  final VoidCallback onSettings;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.brand,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.health_and_safety, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      children: const [
                        TextSpan(text: 'MediGuide'),
                        TextSpan(
                          text: ' · Maternité',
                          style: TextStyle(
                            color: AppColors.brand,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: AppColors.brand,
                        size: 14,
                      ),
                      SizedBox(width: 2),
                      Text('Abidjan, Cocody', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Réglages',
              onPressed: onSettings,
              icon: const Icon(Icons.tune, color: AppColors.primary),
            ),
            IconButton(
              tooltip: 'Profil',
              onPressed: onProfile,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.person_outline),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.surfaceLow,
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.verified_user_outlined,
                color: AppColors.primary,
                size: 16,
              ),
              SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Mode sécurisé · Carnet CPN & fiches d’urgences accessibles',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.check_circle_outline,
                color: AppColors.textSecondary,
                size: 15,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Espace Santé Maternelle',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (dossierName != null)
                    Text(
                      'Dossier suivi : $dossierName',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              tooltip: 'Options du dossier',
              onPressed: onSettings,
              icon: const Icon(Icons.tune),
            ),
          ],
        ),
      ],
    );
  }
}

class MaternityModeTabs extends StatelessWidget {
  const MaternityModeTabs({
    super.key,
    required this.showBaby,
    required this.onChanged,
  });
  final bool showBaby;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: AppColors.surfaceHigh,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        _ModeTab(
          label: 'Ma Grossesse (En cours)',
          selected: !showBaby,
          onTap: () => onChanged(false),
        ),
        _ModeTab(
          label: 'Mon Bébé (0–24 mois)',
          selected: showBaby,
          onTap: () => onChanged(true),
        ),
      ],
    ),
  );
}

class _ModeTab extends StatelessWidget {
  const _ModeTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? AppColors.surface : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                color: selected ? AppColors.primary : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class MaternityEmergencyCard extends StatelessWidget {
  const MaternityEmergencyCard({
    super.key,
    required this.onEmergency,
    required this.onCall,
  });
  final VoidCallback onEmergency;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.emergencyDark,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.monitor_heart_outlined, color: Colors.white, size: 18),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                'PROTOCOLE RÉACTIF OBSTÉTRICAL',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          'Contractions rapprochées, saignements ou perte du liquide amniotique ?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'N’attendez pas votre rendez-vous. Localisez la maternité de garde active dans votre zone.',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: onEmergency,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.emergencyDark,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.emergency),
                label: const Text('Urgences Maternité'),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              tooltip: 'Appeler les urgences maternité',
              onPressed: onCall,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.onEmergencySoft,
                foregroundColor: Colors.white,
                fixedSize: const Size(48, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.phone_in_talk_outlined),
            ),
          ],
        ),
      ],
    ),
  );
}

class PregnancySummaryCard extends StatelessWidget {
  const PregnancySummaryCard({super.key, required this.cpn});

  final CpnEntity? cpn;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.event_note_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Prochaine consultation recommandée',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (cpn == null)
            const Text('Aucune consultation CPN à venir dans le calendrier.')
          else ...[
            Text(
              cpn!.name,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text('Semaine recommandée : ${cpn!.week}'),
            const SizedBox(height: 8),
            const Text(
              'Recommandation du calendrier — aucun rendez-vous confirmé.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    ),
  );
}

class MaternitySectionHeading extends StatelessWidget {
  const MaternitySectionHeading({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.icon,
  });
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      if (actionLabel != null)
        TextButton.icon(
          onPressed: onAction,
          icon: const Icon(Icons.verified_outlined, size: 17),
          label: Text(actionLabel!),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 2),
          ),
        )
      else if (icon != null)
        Icon(icon, color: AppColors.primary, size: 20),
    ],
  );
}

class MaternityExamCard extends StatelessWidget {
  const MaternityExamCard({
    super.key,
    required this.title,
    required this.status,
    this.details,
    this.footer,
    required this.onAction,
    this.actionLabel,
    this.isComplete = false,
  });
  final String title;
  final String status;
  final String? details;
  final String? footer;
  final String? actionLabel;
  final VoidCallback onAction;
  final bool isComplete;

  @override
  Widget build(BuildContext context) {
    final statusColor = isComplete ? AppColors.mint : AppColors.infoSoft;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.infoSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isComplete
                    ? Icons.task_alt
                    : Icons.medical_services_outlined,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 5),
                      MaternityStatusBadge(
                        label: status,
                        background: statusColor,
                        foreground: isComplete
                            ? AppColors.primary
                            : AppColors.info,
                      ),
                    ],
                  ),
                  if (details != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      details!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                  if (footer != null || actionLabel != null) ...[
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        if (footer != null)
                          Expanded(
                          child: Text(
                            footer!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                            ),
                          ),
                          ),
                        if (actionLabel != null)
                          TextButton(
                          onPressed: onAction,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 2,
                            ),
                            minimumSize: const Size(0, 32),
                          ),
                          child: Text(actionLabel!),
                          )
                        else
                          IconButton(
                          tooltip: 'Détails',
                          onPressed: onAction,
                          icon: const Icon(Icons.chevron_right),
                          color: AppColors.textSecondary,
                          visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MaternityAdviceCard extends StatelessWidget {
  const MaternityAdviceCard({
    super.key,
    required this.imageAsset,
    required this.category,
    required this.duration,
    required this.title,
    required this.actionLabel,
    required this.onTap,
  });
  final String imageAsset;
  final String category;
  final String duration;
  final String title;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: SizedBox(
      height: 112,
      child: Row(
        children: [
          SizedBox(
            width: 108,
            height: 112,
            child: Image.asset(
              imageAsset,
              fit: BoxFit.cover,
              semanticLabel: title,
              errorBuilder: (context, error, stackTrace) =>
                  const ColoredBox(color: AppColors.surfaceHigh),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(9, 8, 10, 7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: MaternityStatusBadge(
                          label: category,
                          background: AppColors.mint,
                          foreground: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        duration,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  InkWell(
                    onTap: onTap,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            actionLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward,
                          color: AppColors.primary,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class MaternityListeningLine extends StatelessWidget {
  const MaternityListeningLine({super.key, required this.onContact});
  final VoidCallback onContact;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.surfaceLow,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            color: AppColors.infoSoft,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.support_agent, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ligne d’écoute Maternité',
                style: Theme.of(context).textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                'Sages-femmes disponibles 24h/7j pour conseil non-urgent',
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: AppColors.textSecondary, fontSize: 10),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: onContact,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.info,
            minimumSize: const Size(88, 42),
            padding: const EdgeInsets.symmetric(horizontal: 10),
          ),
          child: const Text('Contacter'),
        ),
      ],
    ),
  );
}

class MaternityStatusBadge extends StatelessWidget {
  const MaternityStatusBadge({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
  });
  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(maxWidth: 160),
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(7),
    ),
    child: Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: foreground,
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class MaternityDetailLine extends StatelessWidget {
  const MaternityDetailLine({
    super.key,
    required this.icon,
    required this.text,
  });
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      children: [
        Icon(icon, size: 15, color: AppColors.textSecondary),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ],
    ),
  );
}

class MaternityNotice extends StatelessWidget {
  const MaternityNotice({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.surfaceLow,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
  );
}
