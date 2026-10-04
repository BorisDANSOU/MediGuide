import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/app_bottom_bar.dart';

/// La "coquille" de l'application : elle affiche l'onglet courant
/// (navigationShell) avec la barre du bas et le bouton Urgences par-dessus.
/// 5 onglets : Accueil (0), Carte (1), Urgences (2), Maternité (3), Profil (4)
class MainShellPage extends StatelessWidget {
  const MainShellPage({super.key, required this.navigationShell});

  /// Fourni par go_router : sait quel onglet est actif et permet d'en changer
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Le contenu de l'onglet actif
      body: navigationShell,

      // Bouton rouge Urgences, posé au centre, à cheval sur la barre.
      // Son apparence (rouge, rond) vient du thème.
      floatingActionButton: FloatingActionButton(
        onPressed: () => navigationShell.goBranch(
          2,
          initialLocation: navigationShell.currentIndex == 2,
        ),
        child: const Icon(Icons.emergency, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: AppBottomBar(
        currentIndex: navigationShell.currentIndex,
        // goBranch change d'onglet. Si on retouche l'onglet déjà actif,
        // initialLocation: true revient à sa première page.
        onTabSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
