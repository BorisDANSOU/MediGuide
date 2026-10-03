import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/auth_page.dart';
import '../../features/emergency/presentation/pages/emergency_modal_page.dart';
import '../../features/health_centers/domain/entities/center_filter.dart';
import '../../features/health_centers/domain/entities/nearby_center.dart';
import '../../features/health_centers/presentation/pages/health_center_detail_page.dart';
import '../../features/health_centers/presentation/pages/map_page.dart';
import '../../features/health_centers/presentation/pages/search_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
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
  static const String profile = '/profile';
  static const String emergency = '/emergency';
  static const String auth = '/auth';

  /// Recherche, dans l'onglet Accueil : `/home/search?filter=guard`.
  static const String search = '/home/search';

  /// Fiche d'un centre, dans l'onglet Accueil (le centre passe en `extra`).
  static const String center = '/home/center';

  static String searchWith(CenterFilter filter) =>
      filter == CenterFilter.all ? search : '$search?filter=${filter.name}';
}

/// Crée le routeur. [initialLocation] sert aux tests.
GoRouter createAppRouter({String initialLocation = AppRoutes.splash}) =>
    GoRouter(
      initialLocation: initialLocation,
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
            // Onglet 0 : Accueil (KABORE), avec la recherche et la fiche
            // en sous-pages : la barre du bas reste visible.
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.home,
                  builder: (context, state) => const HomePage(),
                  routes: [
                    GoRoute(
                      path: 'search',
                      builder: (context, state) => SearchPage(
                        initialFilter: CenterFilter.values.firstWhere(
                          (f) => f.name == state.uri.queryParameters['filter'],
                          orElse: () => CenterFilter.all,
                        ),
                      ),
                    ),
                    GoRoute(
                      path: 'center',
                      builder: (context, state) {
                        final item = state.extra! as NearbyCenter;
                        return HealthCenterDetailPage(
                          center: item.center,
                          distanceKm: item.distanceKm,
                        );
                      },
                    ),
                  ],
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

            // Onglet 3 : Profil (DANSOU)
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

        // Urgences : hors des onglets, s'ouvre par-dessus (bouton rouge).
        // Page de DJOBO : il la complétera, la route n'aura pas à changer.
        GoRoute(
          path: AppRoutes.emergency,
          builder: (context, state) => const EmergencyModalPage(),
        ),

        // Connexion / inscription (KABORE), plein écran sans barre du bas.
        GoRoute(
          path: AppRoutes.auth,
          builder: (context, state) => const AuthPage(),
        ),
      ],
    );

/// Le routeur de l'application.
final GoRouter appRouter = createAppRouter();
