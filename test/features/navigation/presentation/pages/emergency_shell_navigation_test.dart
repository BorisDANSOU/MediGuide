import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediguid/config/routes/app_routes.dart';
import 'package:mediguid/features/navigation/presentation/widgets/app_bottom_bar.dart';

import '../../../../helpers.dart';

void main() {
  testWidgets('opens Urgences from the FAB while keeping the shell visible', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester, location: AppRoutes.home);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Numéros d’Urgence Vitale'), findsOneWidget);
    expect(find.byType(AppBottomBar), findsOneWidget);
    expect(find.text('Maternité'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
  });
}
