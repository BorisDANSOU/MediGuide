import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mediguid/core/theme/app_theme.dart';
import 'package:mediguid/features/emergency/domain/entities/emergency_hospital_entity.dart';
import 'package:mediguid/features/emergency/domain/entities/emergency_number_entity.dart';
import 'package:mediguid/features/emergency/domain/entities/emergency_pharmacy_entity.dart';
import 'package:mediguid/features/emergency/domain/entities/user_location_entity.dart';
import 'package:mediguid/features/emergency/domain/repositories/emergency_repository.dart';
import 'package:mediguid/features/emergency/presentation/pages/emergency_modal_page.dart';
import 'package:mediguid/features/user_profile/presentation/controllers/user_profile_controller.dart';

void main() {
  testWidgets('renders the emergency sections and loaded location', (
    WidgetTester tester,
  ) async {
    await _pumpEmergencyPage(tester);

    expect(find.text('Numéros d’Urgence Vitale'), findsOneWidget);
    expect(find.text('Services nationaux prioritaires'), findsOneWidget);
    expect(find.text('SAMU Médical'), findsOneWidget);
    expect(find.text('Urgences Hospitalières'), findsOneWidget);
    expect(find.text('Aucun hôpital trouvé à proximité.'), findsOneWidget);
    expect(find.text('Pharmacies de Garde Immédiates'), findsOneWidget);
    expect(find.text('Aucune pharmacie de garde trouvée.'), findsOneWidget);
    expect(find.text('Lomé, Centre'), findsOneWidget);
    expect(find.text('Conseil d’appel d’urgence'), findsOneWidget);
  });

  testWidgets('launches the selected emergency number', (
    WidgetTester tester,
  ) async {
    final launchedUris = <Uri>[];
    await _pumpEmergencyPage(
      tester,
      launchUri: (uri) async {
        launchedUris.add(uri);
        return true;
      },
    );

    await tester.tap(find.text('Appeler SAMU Médical'));
    await tester.pumpAndSettle();

    expect(launchedUris, [Uri(scheme: 'tel', path: '185')]);
  });
}

Future<void> _pumpEmergencyPage(
  WidgetTester tester, {
  Future<bool> Function(Uri uri)? launchUri,
}) async {
  SharedPreferences.setMockInitialValues({
    'profile_country': 'Togo',
    'profile_city': 'Lomé',
  });
  final preferences = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: EmergencyModalPage(
          launchUri: launchUri,
          repository: _FakeEmergencyRepository(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _FakeEmergencyRepository implements EmergencyRepository {
  @override
  Future<List<EmergencyNumberEntity>> getEmergencyNumbers(
    String countryCode,
  ) async => [
    const EmergencyNumberEntity(
      id: 'tg-samu',
      name: 'SAMU Médical',
      number: '185',
      country: 'TG',
      category: EmergencyCategory.medical,
      description: 'Urgences médicales',
    ),
  ];

  @override
  Future<List<EmergencyHospitalEntity>> getNearbyHospitals({
    required double lat,
    required double lng,
    required String countryCode,
  }) async => const [];

  @override
  Future<List<EmergencyPharmacyEntity>> getNearbyPharmacies({
    required double lat,
    required double lng,
    required String countryCode,
  }) async => const [];

  @override
  Future<UserLocationEntity> getUserLocation({
    required String country,
    required String city,
  }) async => const UserLocationEntity(
    neighborhood: 'Lomé, Centre',
    landmark: 'Près de la place principale',
    lat: 6.13,
    lng: 1.22,
    accuracyM: 50,
  );
}
