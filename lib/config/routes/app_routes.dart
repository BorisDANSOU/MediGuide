import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/auth_page.dart';
import '../../features/emergency/presentation/pages/emergency_modal_page.dart';
import '../../features/health_centers/presentation/pages/map_page.dart';
import '../../features/health_centers/domain/entities/center_filter.dart';
import '../../features/health_centers/domain/entities/nearby_center.dart';
import '../../features/health_centers/presentation/pages/health_center_detail_page.dart';
import '../../features/health_centers/presentation/pages/search_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/maternity/presentation/pages/maternity_dashboard_page.dart';
import '../../features/maternity/presentation/pages/vaccine_schedule_page.dart';
import '../../features/user_profile/presentation/controllers/vaccine_reminder_settings_controller.dart';
import '../../features/navigation/presentation/pages/main_shell_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/user_profile/presentation/pages/profile_page.dart';

/// Chemins des routes centralisés ici : on évite d'écrire '/home'
/// en dur dans les écrans (source de fautes de frappe).
class AppRoutes {
  AppRoutes._(); // Classe utilitaire : pas d'instance

  static const String splash = '/';
  static const String auth = '/auth';
  static const String home = '/home';
  static const String map = '/map';
  static const String maternity = '/maternity';
  static const String vaccines = '/maternity/vaccines';
  static const String profile = '/profile';
  static const String emergency = '/emergency';
  static const String search = '/search';
  static const String center = '/center';

  static String searchWith([CenterFilter filter = CenterFilter.all]) =>
      '$search?filter=${filter.name}';
}

void navigateToVaccineSchedule(GoRouter router) {
  router.go(AppRoutes.vaccines);
}

/// Construit un routeur indépendant, notamment pour les tests.
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
        GoRoute(
          path: AppRoutes.search,
          builder: (context, state) {
            final filterName = state.uri.queryParameters['filter'];
            final filter = CenterFilter.values.firstWhere(
              (value) => value.name == filterName,
              orElse: () => CenterFilter.all,
            );
            return SearchPage(initialFilter: filter);
          },
        ),
        GoRoute(
          path: AppRoutes.center,
          builder: (context, state) {
            final item = state.extra! as NearbyCenter;
            return HealthCenterDetailPage(
              center: item.center,
              distanceKm: item.distanceKm,
            );
          },
        ),

        // Les 5 destinations partagent la même coquille.
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              MainShellPage(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.home,
                  builder: (context, state) => const HomePage(),
                ),
              ],
            ),

            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.map,
                  builder: (context, state) => const MapPage(),
                ),
              ],
            ),

            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.emergency,
                  builder: (context, state) => const EmergencyModalPage(),
                ),
              ],
            ),

            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.maternity,
                  builder: (context, state) => const MaternityDashboardPage(),
                  routes: [
                    GoRoute(
                      path: 'vaccines',
                          builder: (context, state) => Consumer(
                            builder: (context, ref, _) => VaccineSchedulePage(
                              reminderPreferences: ref.read(
                                vaccineReminderPreferencesProvider,
                              ),
                              notificationService: ref.read(
                                notificationServiceProvider,
                              ),
                            ),
                          ),
                    ),
                  ],
                ),
              ],
            ),

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

/// Routeur utilisé par l'application.
final GoRouter appRouter = createAppRouter();
