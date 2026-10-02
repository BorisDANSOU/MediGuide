import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Barre de navigation du bas : 4 onglets + un espace central

class AppBottomBar extends StatelessWidget {
  const AppBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  final int currentIndex;

  /// Appelée quand l'utilisateur touche un onglet, avec son numéro
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 70,
      padding: EdgeInsets.zero,
      color: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      // Découpe ronde dans la barre pour le bouton flottant central
      shape: const CircularNotchedRectangle(),
      notchMargin: 6,
      child: Row(
        children: [
          _NavItem(
            label: 'Accueil',
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            selected: currentIndex == 0,
            onTap: () => onTabSelected(0),
          ),
          _NavItem(
            label: 'Carte',
            icon: Icons.map_outlined,
            activeIcon: Icons.map,
            selected: currentIndex == 1,
            onTap: () => onTabSelected(1),
          ),

          // Emplacement central : le bouton rouge est dessiné par le Scaffold,
          // ici on affiche seulement son libellé, en bas
          const Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Urgences',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.emergency,
                  ),
                ),
              ),
            ),
          ),

          _NavItem(
            label: 'Maternité',
            icon: Icons.pregnant_woman,
            activeIcon: Icons.pregnant_woman,
            selected: currentIndex == 2,
            onTap: () => onTabSelected(2),
          ),
          _NavItem(
            label: 'Profil',
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            selected: currentIndex == 3,
            onTap: () => onTabSelected(3),
          ),
        ],
      ),
    );
  }
}

/// Un onglet : une icône au-dessus d'un libellé.
/// Vert quand il est sélectionné, gris sinon (comme sur les maquettes).
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textSecondary;

    // Expanded : les 4 onglets se partagent la largeur à parts égales
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? activeIcon : icon, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
