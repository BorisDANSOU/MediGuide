import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mediguid/features/home/presentation/pages/home_page.dart';
import 'package:mediguid/features/user_profile/domain/entities/user_profile_entity.dart';

import 'helpers.dart';

const _ouaga = UserProfileEntity(country: 'Burkina Faso', city: 'Ouagadougou');

void main() {
  testWidgets('Affiche les centres de la ville de l’utilisateur', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(const HomePage(profile: _ouaga, userName: 'Awa')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bonjour, Awa 👋'), findsOneWidget);
    expect(find.text('Pharmacies de garde (2)'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('CHU Yalgado Ouédraogo'), 300);
    expect(find.text('CHU Yalgado Ouédraogo'), findsOneWidget);
    expect(find.text('CHU de Cocody'), findsNothing);
  });

  testWidgets('Le raccourci « Hôpitaux » ouvre la recherche filtrée', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const HomePage(profile: _ouaga)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Hôpitaux'));
    await tester.pumpAndSettle();

    expect(
      find.text('2 résultats à Ouagadougou · du plus proche au plus loin'),
      findsOneWidget,
    );
    expect(find.text('Pharmacie du Progrès'), findsNothing);
  });

  testWidgets('Une carte de centre ouvre sa fiche', (tester) async {
    await tester.pumpWidget(wrap(const HomePage(profile: _ouaga)));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('CMA de Pissy'), 300);
    await tester.ensureVisible(find.text('CMA de Pissy'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CMA de Pissy'));
    await tester.pumpAndSettle();

    expect(find.text('Fiche établissement'), findsOneWidget);
    expect(find.text('Mo-Sa 07:00-17:00'), findsOneWidget);
  });

  for (final size in testSizes) {
    testWidgets('Accueil sans débordement en ${size.width.toInt()} px', (
      tester,
    ) async {
      await expectNoOverflow(
        tester,
        const HomePage(profile: _ouaga),
        size: size,
      );
    });
  }

  testWidgets('Accueil sans débordement avec texte ×1,5 en 360 px', (
    tester,
  ) async {
    await expectNoOverflow(
      tester,
      const HomePage(profile: _ouaga, userName: 'Awa'),
      size: const Size(360, 780),
      textScale: 1.5,
    );
  });
}
