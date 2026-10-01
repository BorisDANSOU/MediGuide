
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/splash/presentation/pages/splash_page.dart';

/// Noms des routes centralisés 
class AppRoutes {
  AppRoutes._(); // Classe utilitaire 

  static const String splash = '/';
  static const String home = '/home';
}

/// Le routeur de l'application.
final GoRouter appRouter = GoRouter(
  // L'app démarre toujours sur le Splash
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: AppRoutes.home,
      // TEMPORAIRE : sera remplacée par la coquille avec la BottomNavBar
      builder: (context, state) => const _TempHomePage(),
    ),
  ],
);

/// Page d'accueil provisoire, juste pour vérifier que la navigation marche.
class _TempHomePage extends StatelessWidget {
  const _TempHomePage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Accueil (temporaire)')),
    );
  }
}