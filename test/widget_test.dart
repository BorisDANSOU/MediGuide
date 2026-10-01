import 'package:flutter_test/flutter_test.dart';

import 'package:mediguid/main.dart';

void main() {
  testWidgets('L’application démarre sur la connexion, accès sans compte', (
    tester,
  ) async {
    await tester.pumpWidget(const MediGuideApp());
    await tester.pumpAndSettle();
    expect(find.text('Se connecter'), findsOneWidget);

    await tester.ensureVisible(find.text('Continuer sans compte'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuer sans compte'));
    await tester.pumpAndSettle();

    expect(find.text('Urgence vitale ?'), findsOneWidget);
    expect(find.text('Bonjour 👋'), findsOneWidget);
  });
}
