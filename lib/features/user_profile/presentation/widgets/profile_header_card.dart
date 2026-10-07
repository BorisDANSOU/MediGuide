import 'package:flutter/material.dart';

import '../../../auth/domain/entities/app_user.dart';
import '../../domain/entities/user_profile_entity.dart';

/// Carte du haut : avatar, titre et zone active de l'utilisateur.
class ProfileHeaderCard extends StatelessWidget {
  static const double _compactLayoutThreshold = 200;

  const ProfileHeaderCard({
    super.key,
    required this.profile,
    required this.user,
  });

  final UserProfileEntity profile;
  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final user = this.user;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final avatar = CircleAvatar(
              radius: 32,
              backgroundColor: scheme.primaryContainer,
              child: Icon(Icons.person, size: 36, color: scheme.primary),
            );
            final identity = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.fullName ?? 'Mode visiteur',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (user != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                ] else
                  const SizedBox(height: 4),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  runSpacing: 2,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: scheme.onSurfaceVariant,
                    ),
                    Text(
                      '${profile.city}, ${profile.country}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            );

            if (constraints.maxWidth < _compactLayoutThreshold) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(alignment: Alignment.centerLeft, child: avatar),
                  const SizedBox(height: 12),
                  identity,
                ],
              );
            }

            return Row(
              children: [
                avatar,
                const SizedBox(width: 16),
                Expanded(child: identity),
              ],
            );
          },
        ),
      ),
    );
  }
}
