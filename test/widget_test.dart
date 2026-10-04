import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediguid/main.dart';

void main() {
  testWidgets('MediGuide app renders without crashing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MediGuideApp());
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
