import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mediguid/features/auth/presentation/pages/auth_page.dart';

import 'helpers.dart';

Future<void> _tapVisible(WidgetTester tester, String text) async {
  final finder = find.text(text).last;
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Connexion : champs vides refusés', (tester) async {
    await tester.pumpWidget(wrap(const AuthPage()));
    await _tapVisible(tester, 'Se connecter');

    expect(find.text('Saisissez votre adresse e-mail.'), findsOneWidget);
    expect(find.text('Saisissez votre mot de passe.'), findsOneWidget);
  });

  testWidgets('Connexion : mauvais mot de passe', (tester) async {
    await tester.pumpWidget(wrap(const AuthPage()));
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'demo@mediguide.app',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'mauvais-mdp');
    await _tapVisible(tester, 'Se connecter');

    expect(find.text('Mot de passe incorrect.'), findsOneWidget);
  });

  testWidgets('Connexion avec le compte de démo : accueil à Ouagadougou', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const AuthPage()));
    await _tapVisible(tester, 'Utiliser le compte de démonstration');
    await _tapVisible(tester, 'Se connecter');

    expect(find.text('Bonjour, Utilisateur 👋'), findsOneWidget);
    expect(find.text('Ouagadougou, Burkina Faso'), findsOneWidget);
  });

  testWidgets('Inscription : le pays choisi devient la ville de l’accueil', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const AuthPage(initialMode: AuthMode.signup)));

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Koffi Amavi');
    await tester.enterText(fields.at(1), 'koffi@exemple.ci');
    await _tapVisible(tester, "Côte d'Ivoire");
    expect(find.text('Abidjan'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(2), 'motdepasse1');
    await tester.enterText(find.byType(TextFormField).at(3), 'motdepasse2');
    await _tapVisible(tester, 'Créer mon compte');

    // Mots de passe différents et conditions non acceptées.
    expect(
      find.text('Les deux mots de passe ne sont pas identiques.'),
      findsOneWidget,
    );
    expect(
      find.text('Acceptez les conditions pour continuer.'),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextFormField).at(3), 'motdepasse1');
    final checkbox = find.byType(Checkbox);
    await tester.ensureVisible(checkbox);
    await tester.tap(checkbox);
    await _tapVisible(tester, 'Créer mon compte');

    expect(find.text('Bonjour, Koffi 👋'), findsOneWidget);
    expect(find.text("Abidjan, Côte d'Ivoire"), findsOneWidget);
  });

  for (final size in testSizes) {
    testWidgets('Inscription sans débordement en ${size.width.toInt()} px', (
      tester,
    ) async {
      await expectNoOverflow(
        tester,
        const AuthPage(initialMode: AuthMode.signup),
        size: size,
      );
    });
  }

  testWidgets('Connexion sans débordement avec texte ×1,5 en 360 px', (
    tester,
  ) async {
    await expectNoOverflow(
      tester,
      const AuthPage(),
      size: const Size(360, 780),
      textScale: 1.5,
    );
  });
}
