// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:mediguid/main.dart';

void main() {
  testWidgets('MediGuide app loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MediGuideApp());

    expect(find.text('Bienvenue sur MediGuide'), findsOneWidget);
    expect(find.text('Centres de santé'), findsOneWidget);
  });
}
