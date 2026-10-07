import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mediguid/config/routes/app_routes.dart';
import 'package:mediguid/core/theme/app_theme.dart';
import 'package:mediguid/features/auth/domain/repositories/auth_repository.dart';
import 'package:mediguid/features/auth/presentation/controllers/auth_providers.dart';
import 'package:mediguid/features/health_centers/data/repositories/demo_health_center_repository.dart';
import 'package:mediguid/features/health_centers/domain/repositories/health_center_repository.dart';
import 'package:mediguid/features/health_centers/presentation/controllers/health_centers_providers.dart';
import 'package:mediguid/features/user_profile/presentation/controllers/user_profile_controller.dart';

import 'fakes/fake_auth_repository.dart';

/// Écrans à vérifier : petit téléphone, téléphone courant, tablette.
const testSizes = [Size(320, 640), Size(412, 915), Size(1024, 768)];

/// Un écran seul, sans routeur ni providers (fiche structure).
Widget wrap(Widget child) => MaterialApp(theme: AppTheme.light, home: child);

/// Fixe la taille d'écran et le zoom du texte pour la durée du test.
void setScreen(WidgetTester tester, Size size, {double textScale = 1}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

/// Lance l'application sur [location], avec un profil déjà enregistré
/// (SharedPreferences simulées, comme le recommande la doc du paquet) et un
/// faux dépôt d'authentification à la place de Firebase Auth.
Future<void> pumpApp(
  WidgetTester tester, {
  required String location,
  String country = 'Burkina Faso',
  String city = 'Ouagadougou',
  AuthRepository? auth,
  HealthCenterRepository? healthCenters,
}) async {
  SharedPreferences.setMockInitialValues({
    'profile_country': country,
    'profile_city': city,
  });
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authRepositoryProvider.overrideWithValue(auth ?? FakeAuthRepository()),
        healthCenterRepositoryProvider.overrideWithValue(
          healthCenters ?? const DemoHealthCenterRepository(),
        ),
      ],
      child: MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: createAppRouter(initialLocation: location),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Fait défiler l'écran jusqu'en bas et échoue si un élément déborde.
Future<void> expectNoOverflowWhileScrolling(WidgetTester tester) async {
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

/// Rend [finder] visible puis le touche.
Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}
