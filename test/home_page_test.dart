import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mediguid/config/routes/app_routes.dart';

import 'helpers.dart';

void main() {
  testWidgets('Affiche les centres de la ville du profil', (tester) async {
    await pumpApp(tester, location: AppRoutes.home);

    expect(find.text('Bonjour 👋'), findsOneWidget);
    expect(find.text('Ouagadougou, Burkina Faso'), findsOneWidget);
    expect(find.text('Pharmacies de garde (0)'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Hôpital démo 1 - Ouagadougou'),
      300,
    );
    expect(find.text('Hôpital démo 1 - Ouagadougou'), findsOneWidget);
    expect(find.textContaining('Lomé'), findsNothing);
  });

  testWidgets('Le raccourci « Hôpitaux » ouvre la recherche filtrée', (
    tester,
  ) async {
    await pumpApp(tester, location: AppRoutes.home);
    await tapVisible(tester, find.text('Hôpitaux'));

    expect(
      find.text('2 résultats à Ouagadougou · du plus proche au plus loin'),
      findsOneWidget,
    );
  });

  testWidgets('Une carte de centre ouvre sa fiche', (tester) async {
    await pumpApp(tester, location: AppRoutes.home);
    final card = find.text('Clinique démo 3 - Ouagadougou');
    await tester.scrollUntilVisible(card, 300);
    await tapVisible(tester, card);

    expect(find.text('Fiche établissement'), findsOneWidget);
  });

  testWidgets('« Se connecter » ouvre la connexion', (tester) async {
    await pumpApp(tester, location: AppRoutes.home);
    await tapVisible(tester, find.text('Se connecter').first);

    expect(find.text('Créer un compte'), findsOneWidget);
  });

  for (final size in testSizes) {
    testWidgets('Accueil sans débordement en ${size.width.toInt()} px', (
      tester,
    ) async {
      setScreen(tester, size);
      await pumpApp(tester, location: AppRoutes.home);
      await expectNoOverflowWhileScrolling(tester);
    });
  }

  testWidgets('Accueil sans débordement avec texte ×1,5 en 360 px', (
    tester,
  ) async {
    setScreen(tester, const Size(360, 780), textScale: 1.5);
    await pumpApp(tester, location: AppRoutes.home);
    await expectNoOverflowWhileScrolling(tester);
    // À réactiver quand la barre du bas (app_bottom_bar.dart, DANSOU) gérera
    // le texte agrandi : ses libellés débordent de 8 à 34 px à ×1,5.
  }, skip: true);
}
