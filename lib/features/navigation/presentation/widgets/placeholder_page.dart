import 'package:flutter/material.dart';

/// Page TEMPORAIRE affichée à la place d'un écran pas encore développé.
/// Chaque développeur la remplace dans app_routes.dart par son vrai écran,
/// puis ce fichier pourra être supprimé.
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          '$title\n(écran à venir)',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
