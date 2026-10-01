import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mediguid/features/health_centers/domain/entities/center_filter.dart';
import 'package:mediguid/features/health_centers/domain/entities/health_center_entity.dart';
import 'package:mediguid/features/health_centers/domain/entities/nearby_center.dart';
import 'package:mediguid/features/health_centers/domain/usecases/filter_health_centers.dart';
import 'package:mediguid/features/health_centers/presentation/pages/health_center_detail_page.dart';
import 'package:mediguid/features/health_centers/presentation/pages/search_page.dart';

import 'helpers.dart';

NearbyCenter _n(HealthCenterEntity c, double km) =>
    NearbyCenter(center: c, distanceKm: km);

const _yalgado = HealthCenterEntity(
  id: 'y',
  name: 'CHU Yalgado Ouédraogo',
  type: 'hospital',
  latitude: 12.37,
  longitude: -1.51,
  address: 'Avenue Kwame Nkrumah',
  phone: '+226 25 31 16 55',
  is24h: true,
);
const _pharma = HealthCenterEntity(
  id: 'p',
  name: 'Pharmacie du Progrès',
  type: 'pharmacy',
  latitude: 12.36,
  longitude: -1.52,
  isGuard: true,
);

void main() {
  group('FilterHealthCenters', () {
    const filter = FilterHealthCenters();
    final list = [_n(_yalgado, 1), _n(_pharma, 2)];

    test('ignore les accents et la casse', () {
      expect(filter(list, query: 'ouedraogo').single.center.id, 'y');
      expect(filter(list, query: 'PROGRES').single.center.id, 'p');
    });

    test('cherche aussi par type et par adresse', () {
      expect(filter(list, query: 'pharmacie').single.center.id, 'p');
      expect(filter(list, query: 'nkrumah').single.center.id, 'y');
    });

    test('combine texte et puce', () {
      expect(filter(list, filter: CenterFilter.guard).single.center.id, 'p');
      expect(filter(list, query: 'chu', filter: CenterFilter.guard), isEmpty);
    });
  });

  group('SearchPage', () {
    const page = SearchPage(country: 'Burkina Faso', city: 'Ouagadougou');

    testWidgets('filtre en direct puis propose de tout effacer', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(page));
      await tester.pumpAndSettle();
      expect(find.textContaining('5 résultats'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'yalgado');
      await tester.pumpAndSettle();
      expect(find.textContaining('1 résultat '), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pumpAndSettle();
      expect(find.textContaining('Aucun centre trouvé'), findsOneWidget);

      await tester.tap(find.text('Tout effacer'));
      await tester.pumpAndSettle();
      expect(find.textContaining('5 résultats'), findsOneWidget);
    });

    testWidgets('la puce « De garde » ne garde que les pharmacies de garde', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(page));
      await tester.pumpAndSettle();
      final chip = find.widgetWithText(ChoiceChip, 'De garde');
      await tester.ensureVisible(chip);
      await tester.pumpAndSettle();
      await tester.tap(chip);
      await tester.pumpAndSettle();

      expect(find.textContaining('2 résultats'), findsOneWidget);
      expect(find.text('CHU Yalgado Ouédraogo'), findsNothing);
    });

    for (final size in testSizes) {
      testWidgets('sans débordement en ${size.width.toInt()} px', (
        tester,
      ) async {
        await expectNoOverflow(tester, page, size: size);
      });
    }
  });

  group('HealthCenterDetailPage', () {
    testWidgets('« Appeler » masqué quand il n’y a pas de numéro', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(const HealthCenterDetailPage(center: _pharma, distanceKm: 0.8)),
      );
      expect(find.text('Appeler'), findsNothing);
      expect(find.text('Itinéraire'), findsOneWidget);
      expect(find.text('Numéro non renseigné'), findsOneWidget);
      expect(find.text('De garde'), findsOneWidget);
    });

    testWidgets('« Appeler » affiché avec le numéro', (tester) async {
      await tester.pumpWidget(
        wrap(const HealthCenterDetailPage(center: _yalgado, distanceKm: 1.2)),
      );
      expect(find.text('Appeler'), findsOneWidget);
      expect(find.text('24h/24, 7j/7'), findsOneWidget);
    });

    for (final size in [...testSizes, const Size(360, 780)]) {
      testWidgets('sans débordement en ${size.width.toInt()} px', (
        tester,
      ) async {
        await expectNoOverflow(
          tester,
          const HealthCenterDetailPage(center: _yalgado, distanceKm: 1.2),
          size: size,
          textScale: size.width == 360 ? 1.5 : 1,
        );
      });
    }
  });
}
