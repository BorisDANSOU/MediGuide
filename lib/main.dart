import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/auth_page.dart';

void main() {
  runApp(const MediGuideApp());
}

class MediGuideApp extends StatelessWidget {
  const MediGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediGuide',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // En attendant le splash et la vérification de session (DANSOU).
      home: const AuthPage(),
    );
  }
}
