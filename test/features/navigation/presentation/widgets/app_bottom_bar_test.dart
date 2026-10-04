import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediguid/features/navigation/presentation/widgets/app_bottom_bar.dart';

void main() {
  testWidgets('keeps Maternity and Profile after the emergency branch', (
    WidgetTester tester,
  ) async {
    final selectedIndices = <int>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: AppBottomBar(
            currentIndex: 3,
            onTabSelected: selectedIndices.add,
          ),
        ),
      ),
    );

    expect(find.text('Accueil'), findsOneWidget);
    expect(find.text('Carte'), findsOneWidget);
    expect(find.text('Urgences'), findsOneWidget);
    expect(find.text('Maternité'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);

    await tester.tap(find.text('Maternité'));
    expect(selectedIndices, [3]);

    await tester.tap(find.text('Profil'));
    expect(selectedIndices, [3, 4]);
  });
}
