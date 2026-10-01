import 'package:go_router/go_router.dart';

import '../../features/navigation/presentation/pages/main_shell_page.dart';
import '../../features/navigation/presentation/widgets/placeholder_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/user_profile/presentation/pages/profile_page.dart';
import '../../features/emergency/presentation/pages/emergency_modal_page.dart';

/// Chemins des routes centralisés ici : on évite d'écrire '/home'
/// en dur dans les écrans (source de fautes de frappe).
class AppRoutes {
  AppRoutes._(); // Classe utilitaire : pas d'instance

  static const String splash = '/';
  static const String home = '/home';
  static const String map = '/map';
  static const String maternity = '/maternity';
  static const String profile = '/profile';
  static const String emergency = '/emergency';
}

/// Le routeur de l'application.
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashPage(),
    ),

    // Les 4 onglets partagent la même coquille (barre du bas).
    // indexedStack garde chaque onglet en mémoire : on retrouve
    // la carte telle qu'on l'a laissée en revenant dessus.
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainShellPage(navigationShell: navigationShell),
      branches: [
        // Onglet 0 : Accueil (KABORE remplacera PlaceholderPage)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) =>
                  const PlaceholderPage(title: 'Accueil'),
            ),
          ],
        ),

        // Onglet 3 : Profil
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),

        // Onglet 2 : Maternité (NOUMEDOR remplacera PlaceholderPage)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.maternity,
              builder: (context, state) =>
                  const PlaceholderPage(title: 'Maternité'),
            ),
          ],
        ),

        // Onglet 3 : Profil (DANSOU : profile_page.dart, plus tard)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) =>
                  const PlaceholderPage(title: 'Profil'),
            ),
          ],
        ),
      ],
    ),

    // Urgences : hors des onglets, s'ouvre par-dessus (bouton rouge).
    GoRoute(
      path: AppRoutes.emergency,
      // Page de DJOBO : il la complétera, la route n'aura pas à changer
      builder: (context, state) => const EmergencyModalPage(),
    ),
  ],
);
