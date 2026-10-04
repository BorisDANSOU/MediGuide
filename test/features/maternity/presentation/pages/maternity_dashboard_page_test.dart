import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediguid/features/maternity/presentation/pages/maternity_dashboard_page.dart';

void main() {
  testWidgets('renders the maternity dashboard mockup sections', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: MaternityDashboardPage()));
    await tester.pumpAndSettle();

    expect(find.text('Espace Santé Maternelle'), findsOneWidget);
    expect(find.text('PROTOCOLE RÉACTIF OBSTÉTRICAL'), findsOneWidget);
    expect(find.text('Consultation Prénatale (CPN 3)'), findsOneWidget);
    expect(find.text('Échéances & Examens Recommandés'), findsOneWidget);
    expect(find.text('Repères & Conseils Validés'), findsOneWidget);
    expect(find.text('Ligne d’écoute Maternité'), findsOneWidget);
    expect(find.byType(Image), findsNWidgets(3));
  });

  testWidgets('switches between pregnancy and baby schedules', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: MaternityDashboardPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mon Bébé (0–24 mois)'));
    await tester.pumpAndSettle();
    expect(find.text('BCG'), findsOneWidget);

    await tester.tap(find.text('Ma Grossesse (En cours)'));
    await tester.pumpAndSettle();
    expect(find.text('28e SA (7ème mois)'), findsOneWidget);
  });
}
