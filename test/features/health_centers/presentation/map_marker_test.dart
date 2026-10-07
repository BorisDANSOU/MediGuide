import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediguid/config/routes/app_routes.dart';
import 'package:mediguid/features/health_centers/domain/entities/health_center_entity.dart';

import '../../../fakes/fake_health_center_repository.dart';
import '../../../helpers.dart';

void main() {
  const centers = [
    HealthCenterEntity(
      id: 'hospital-1',
      name: 'Hôpital de test',
      type: 'hospital',
      latitude: 12.3714,
      longitude: -1.56,
      city: 'Ouagadougou',
      country: 'Burkina Faso',
      phone: '+226 25 30 66 44',
    ),
    HealthCenterEntity(
      id: 'clinic-1',
      name: 'Clinique sans téléphone',
      type: 'clinic',
      latitude: 12.3714,
      longitude: -1.52,
      city: 'Ouagadougou',
      country: 'Burkina Faso',
    ),
    HealthCenterEntity(
      id: 'pharmacy-1',
      name: 'Pharmacie de test',
      type: 'pharmacy',
      latitude: 12.3714,
      longitude: -1.48,
      city: 'Ouagadougou',
      country: 'Burkina Faso',
      phone: '+226 25 30 00 00',
      isGuard: true,
    ),
  ];

  testWidgets(
    'les trois marqueurs ouvrent leur fiche et respectent les infos disponibles',
    (tester) async {
      await pumpApp(
        tester,
        location: AppRoutes.map,
        healthCenters: FakeHealthCenterRepository(centers: centers),
      );

      const markers = [
        (icon: Icons.local_hospital, name: 'Hôpital de test', phone: true),
        (
          icon: Icons.medical_services,
          name: 'Clinique sans téléphone',
          phone: false,
        ),
        (icon: Icons.local_pharmacy, name: 'Pharmacie de test', phone: true),
      ];

      for (final marker in markers) {
        final pin = find.byIcon(marker.icon).hitTestable();
        expect(pin, findsOneWidget);
        await tester.tap(pin);
        await tester.pumpAndSettle();

        expect(find.text(marker.name), findsOneWidget);
        expect(
          find.text('Appeler'),
          marker.phone ? findsOneWidget : findsNothing,
        );
        if (marker.name == 'Pharmacie de test') {
          expect(find.text('Pharmacie de garde'), findsOneWidget);
        }

        await tester.tapAt(const Offset(4, 4));
        await tester.pumpAndSettle();
      }
    },
  );

  testWidgets('les marqueurs superposés sont regroupés avec leur nombre', (
    tester,
  ) async {
    final overlappingCenters = [
      for (var index = 0; index < centers.length; index++)
        HealthCenterEntity(
          id: 'overlapping-$index',
          name: centers[index].name,
          type: centers[index].type,
          latitude: 12.3714,
          longitude: -1.5197,
          city: 'Ouagadougou',
          country: 'Burkina Faso',
        ),
    ];

    await pumpApp(
      tester,
      location: AppRoutes.map,
      healthCenters: FakeHealthCenterRepository(centers: overlappingCenters),
    );

    expect(find.text('3'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
