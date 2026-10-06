import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/auth_page.dart';
import '../../features/emergency/presentation/pages/emergency_modal_page.dart';
import '../../features/health_centers/domain/entities/center_filter.dart';
import '../../features/health_centers/domain/entities/nearby_center.dart';
import '../../features/health_centers/presentation/pages/health_center_detail_page.dart';
import '../../features/health_centers/presentation/pages/map_page.dart';
import '../../features/health_centers/presentation/pages/search_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/maternity/presentation/pages/maternity_dashboard_page.dart';
import '../../features/maternity/presentation/pages/vaccine_schedule_page.dart';
import '../../features/navigation/presentation/pages/main_shell_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/user_profile/presentation/pages/profile_page.dart';

/// Chemins des routes centralisés ici 
class AppRoutes {
  AppRoutes._(); // Classe utilitaire 

  static const String splash = '/';
  static const String home = '/home';
  static const String map = '/map';
  static const String maternity = '/maternity';
  static const String vaccines = '/maternity/vaccines';
  static const String profile = '/profile';
  static const String emergency = '/emergency';
  static const String auth = '/auth';

  static const String search = '/home/search';

  static const String center = '/home/center';

  static String searchWith(CenterFilter filter) =>
      filter == CenterFilter.all ? search : '$search?filter=${filter.name}';
}

/// Crée le routeur. initialLocation sert aux tests.
GoRouter createAppRouter({String initialLocation = AppRoutes.splash}) =>
    GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const SplashPage(),
        ),

        GoRoute(
          path: AppRoutes.auth,
          builder: (context, state) => const AuthPage(),
        ),

        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              MainShellPage(navigationShell: navigationShell),
          branches: [
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

            // Onglet 2 : Urgences (DJOBO / NOUMEDOR), bouton central
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.emergency,
                  builder: (context, state) => const EmergencyModalPage(),
                ),
              ],
            ),

            // Onglet 3 : Maternité (NOUMEDOR), avec le calendrier vaccinal
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

/// Le routeur de l'application.
final GoRouter appRouter = createAppRouter();