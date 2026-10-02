import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mediguid/config/routes/app_routes.dart';

import 'helpers.dart';

Future<void> _tap(WidgetTester tester, String text) =>
    tapVisible(tester, find.text(text).last);

void main() {
  testWidgets('Connexion : champs vides refusés', (tester) async {
    await pumpApp(tester, location: AppRoutes.auth);
    await _tap(tester, 'Se connecter');

    expect(find.text('Saisissez votre adresse e-mail.'), findsOneWidget);
    expect(find.text('Saisissez votre mot de passe.'), findsOneWidget);
  });

  testWidgets('Connexion : mauvais mot de passe', (tester) async {
    await pumpApp(tester, location: AppRoutes.auth);
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'demo@mediguide.app',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'mauvais-mdp');
    await _tap(tester, 'Se connecter');

    expect(find.text('Mot de passe incorrect.'), findsOneWidget);
  });

  testWidgets('Compte de démo : accueil à Ouagadougou avec le prénom', (
    tester,
  ) async {
    // Profil enregistré sur un autre pays : la connexion doit le corriger.
    await pumpApp(
      tester,
      location: AppRoutes.auth,
      country: 'Togo',
      city: 'Lomé',
    );
    await _tap(tester, 'Utiliser le compte de démonstration');
    await _tap(tester, 'Se connecter');

    expect(find.text('Bonjour, Utilisateur 👋'), findsOneWidget);
    expect(find.text('Ouagadougou, Burkina Faso'), findsOneWidget);
    expect(find.text('Se connecter'), findsNothing);
  });

  testWidgets('Inscription : le pays choisi devient celui de l’accueil', (
    tester,
  ) async {
    await pumpApp(tester, location: AppRoutes.auth);
    await _tap(tester, 'Créer un compte');

    await tester.enterText(find.byType(TextFormField).at(0), 'Koffi Amavi');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'koffi@exemple.ci',
    );
    await _tap(tester, "Côte d'Ivoire");
    expect(find.text('Abidjan'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(2), 'motdepasse1');
    await tester.enterText(find.byType(TextFormField).at(3), 'motdepasse2');
    await _tap(tester, 'Créer mon compte');

    expect(
      find.text('Les deux mots de passe ne sont pas identiques.'),
      findsOneWidget,
    );
    expect(
      find.text('Acceptez les conditions pour continuer.'),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextFormField).at(3), 'motdepasse1');
    await tapVisible(tester, find.byType(Checkbox));
    await _tap(tester, 'Créer mon compte');

    expect(find.text('Bonjour, Koffi 👋'), findsOneWidget);
    expect(find.text("Abidjan, Côte d'Ivoire"), findsOneWidget);
  });

  testWidgets('« Continuer sans compte » ouvre l’accueil', (tester) async {
    await pumpApp(tester, location: AppRoutes.auth);
    await _tap(tester, 'Continuer sans compte');

    expect(find.text('Urgence vitale ?'), findsOneWidget);
  });

  for (final size in testSizes) {
    testWidgets('Inscription sans débordement en ${size.width.toInt()} px', (
      tester,
    ) async {
      setScreen(tester, size);
      await pumpApp(tester, location: AppRoutes.auth);
      await _tap(tester, 'Créer un compte');
      await expectNoOverflowWhileScrolling(tester);
    });
  }

  testWidgets('Connexion sans débordement avec texte ×1,5 en 360 px', (
    tester,
  ) async {
    setScreen(tester, const Size(360, 780), textScale: 1.5);
    await pumpApp(tester, location: AppRoutes.auth);
    await expectNoOverflowWhileScrolling(tester);
  });
}
