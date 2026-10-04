import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediguid/features/emergency/domain/entities/emergency_number_entity.dart';
import 'package:mediguid/features/emergency/domain/repositories/emergency_repository.dart';
import 'package:mediguid/features/emergency/presentation/pages/emergency_modal_page.dart';

void main() {
  testWidgets('renders the emergency demo sections', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: EmergencyModalPage(
          repository: _FakeEmergencyRepository(
            numbers: const [
              EmergencyNumberEntity(
                id: 'samu',
                name: 'SAMU Médical',
                number: '185',
                country: 'Côte d’Ivoire',
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Données de démonstration.'), findsOneWidget);
    expect(find.text('Numéros d’Urgence Vitale'), findsOneWidget);
    expect(find.textContaining('Côte d’Ivoire • Abidjan'), findsOneWidget);
    expect(find.text('Services nationaux prioritaires'), findsOneWidget);
    expect(find.text('Urgences Hospitalières'), findsOneWidget);
    expect(find.text('CHU de Cocody'), findsOneWidget);
    expect(find.text('Urgences Médico-Chirurgicales PISAM'), findsOneWidget);
    expect(find.text('Pharmacies de Garde Immédiates'), findsOneWidget);
    expect(find.text('Conseil d’appel d’urgence'), findsOneWidget);
  });

  testWidgets('opens the phone dialer with the selected emergency number', (
    WidgetTester tester,
  ) async {
    final launchedUris = <Uri>[];
    await tester.pumpWidget(
      MaterialApp(
        home: EmergencyModalPage(
          launchUri: (uri) async {
            launchedUris.add(uri);
            return true;
          },
          repository: _FakeEmergencyRepository(
            numbers: const [
              EmergencyNumberEntity(
                id: 'samu',
                name: 'SAMU Médical',
                number: '185',
                country: 'Côte d’Ivoire',
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Appeler SAMU Médical (185)'));
    await tester.pumpAndSettle();

    expect(launchedUris, [Uri(scheme: 'tel', path: '185')]);
  });

  testWidgets('offers police numbers as separate dialer actions', (
    WidgetTester tester,
  ) async {
    final launchedUris = <Uri>[];
    await tester.pumpWidget(
      MaterialApp(
        home: EmergencyModalPage(
          launchUri: (uri) async {
            launchedUris.add(uri);
            return true;
          },
          repository: _FakeEmergencyRepository(
            numbers: const [
              EmergencyNumberEntity(
                id: 'police',
                name: 'Police Secours',
                number: '170 / 111',
                country: 'Côte d’Ivoire',
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Composer 170'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Composer 111'));
    await tester.pumpAndSettle();

    expect(launchedUris, [
      Uri(scheme: 'tel', path: '170'),
      Uri(scheme: 'tel', path: '111'),
    ]);
  });
}

class _FakeEmergencyRepository implements EmergencyRepository {
  const _FakeEmergencyRepository({this.numbers = const []});

  final List<EmergencyNumberEntity> numbers;

  @override
  Future<List<EmergencyNumberEntity>> getEmergenciesByCountry(
    String country,
  ) async => numbers.where((item) => item.country == country).toList();
}
