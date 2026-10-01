import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mediguid/core/theme/app_theme.dart';

/// Écrans à vérifier : petit téléphone, téléphone courant, tablette.
const testSizes = [Size(320, 640), Size(412, 915), Size(1024, 768)];

Widget wrap(Widget child) =>
    MaterialApp(theme: AppTheme.lightTheme, home: child);

/// Affiche [child] à la taille [size] (et au zoom de texte [textScale]),
/// fait défiler tout l'écran et échoue si un élément déborde.
Future<void> expectNoOverflow(
  WidgetTester tester,
  Widget child, {
  required Size size,
  double textScale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  await tester.pumpWidget(wrap(child));
  await tester.pumpAndSettle();
  // Le défilement vertical de l'écran (pas celui, horizontal, des champs).
  final scrollable = find
      .byWidgetPredicate(
        (w) =>
            w is Scrollable &&
            axisDirectionToAxis(w.axisDirection) == Axis.vertical,
      )
      .hitTestable();
  if (scrollable.evaluate().isNotEmpty) {
    await tester.drag(scrollable.first, const Offset(0, -5000));
    await tester.pumpAndSettle();
  }
  expect(tester.takeException(), isNull);
}
