import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'debug/seed_debug_page.dart';
import 'firebase_options.dart';
import 'services/firestore_offline.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  configureFirestoreOffline();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'MediGuide',
      debugShowCheckedModeBanner: false,
      // TEMPORAIRE : `home` est le premier écran affiché au lancement.
      // Une fois le seeding fait, remplace SeedDebugPage() par l'écran
      // normal de l'app (ex: SplashScreen()).
      home: SeedDebugPage(),
    );
  }
}
