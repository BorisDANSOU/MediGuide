import 'package:flutter_test/flutter_test.dart';
import 'package:mediguid/config/routes/app_routes.dart';
import 'package:mediguid/features/health_centers/domain/failures/health_center_access_failure.dart';

import '../../../../fakes/fake_health_center_repository.dart';
import '../../../../helpers.dart';

void main() {
  testWidgets(
    'la carte affiche la connexion requise après un refus Firestore',
    (tester) async {
      await pumpApp(
        tester,
        location: AppRoutes.map,
        healthCenters: FakeHealthCenterRepository(
          error: const HealthCenterAccessFailure(),
        ),
      );

      expect(
        find.text('Connectez-vous pour afficher les centres de santé.'),
        findsOneWidget,
      );
      expect(find.text('Se connecter'), findsOneWidget);
    },
  );

  testWidgets('la carte expose un réessai pour les erreurs réseau', (
    tester,
  ) async {
    await pumpApp(
      tester,
      location: AppRoutes.map,
      healthCenters: FakeHealthCenterRepository(error: Exception('offline')),
    );

    expect(
      find.text('Impossible de charger les centres de santé.'),
      findsOneWidget,
    );
    expect(find.text('Réessayer'), findsOneWidget);
  });
}
