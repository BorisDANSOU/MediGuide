import 'package:go_router/go_router.dart';

import '../../features/emergency/presentation/pages/emergency_modal_page.dart';
import '../../features/health_centers/presentation/pages/map_page.dart';
import '../../features/maternity/presentation/pages/maternity_dashboard_page.dart';
import '../../features/maternity/presentation/pages/vaccine_schedule_page.dart';
import '../../features/navigation/presentation/pages/main_shell_page.dart';
import '../../features/navigation/presentation/widgets/placeholder_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/user_profile/presentation/pages/profile_page.dart';

/// Chemins des routes centralisés ici : on évite d'écrire '/home'
/// en dur dans les écrans (source de fautes de frappe).
class AppRoutes {
  AppRoutes._(); // Classe utilitaire : pas d'instance

  static const String splash = '/';
  static const String home = '/home';
  static const String map = '/map';
  static const String maternity = '/maternity';
  static const String vaccines = '/maternity/vaccines';
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

    // Les 5 destinations partagent la même coquille (barre du bas).
    // indexedStack garde chaque destination en mémoire : on retrouve
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

        // Onglet 1 : Carte (DANSOU)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.map,
              builder: (context, state) => const MapPage(),
            ),
          ],
        ),

        // Onglet 2 : Urgences
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.emergency,
              builder: (context, state) => const EmergencyModalPage(),
            ),
          ],
        ),

        // Onglet 3 : Maternité (NOUMEDOR)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.maternity,
              builder: (context, state) => const MaternityDashboardPage(),
              routes: [
                GoRoute(
                  path: 'vaccines',
                  builder: (context, state) => const VaccineSchedulePage(),
                ),
              ],
            ),
          ],
        ),

        // Onglet 4 : Profil (DANSOU)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
