import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/user_profile/presentation/controllers/user_profile_controller.dart';

// main devient "async" : on doit attendre le chargement de SharedPreferences
Future<void> main() async {
  // Nécessaire avant toute initialisation asynchrone
  // (Firebase, GetIt... seront ajoutés ici plus tard)
  WidgetsFlutterBinding.ensureInitialized();

  // Chargement du stockage local, une seule fois, au démarrage
  final prefs = await SharedPreferences.getInstance();

  runApp(
    // ProviderScope : le conteneur Riverpod, qui doit envelopper toute l'app.
    // "overrides" fournit la vraie valeur de sharedPreferencesProvider.
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const MediGuideApp(),
    ),
  );
}

class MediGuideApp extends StatelessWidget {
  const MediGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp.router (et non MaterialApp) : obligatoire avec go_router
    return MaterialApp.router(
      title: 'MediGuide',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
