import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/routes/app_routes.dart';

void main() {
  // Nécessaire avant toute initialisation asynchrone
  // (Firebase, GetIt... seront ajoutés ici plus tard)
  WidgetsFlutterBinding.ensureInitialized();

  // ProviderScope : le conteneur Riverpod. Il doit envelopper toute l'app,
  // sinon aucun provider ne fonctionne.
  runApp(const ProviderScope(child: MediGuideApp()));
}

class MediGuideApp extends StatelessWidget {
  const MediGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp.router (et non MaterialApp) : obligatoire avec go_router
    return MaterialApp.router(
      title: 'MediGuide',
      debugShowCheckedModeBanner: false,
      // THÈME TEMPORAIRE : remplacé par core/theme/app_theme.dart
      // quand l'équipe aura validé la palette.
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      routerConfig: appRouter,
    );
  }
}
