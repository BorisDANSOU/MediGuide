import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediguid/features/maternity/domain/entities/cpn_entity.dart';
import 'package:mediguid/features/maternity/domain/entities/vaccine_entity.dart';
import 'package:mediguid/features/maternity/domain/repositories/maternity_repository.dart';
import 'package:mediguid/features/maternity/presentation/pages/vaccine_schedule_page.dart';

void main() {
  testWidgets('renders vaccines loaded from the local repository', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: VaccineSchedulePage(
          repository: _FakeMaternityRepository(
            vaccines: const [
              VaccineEntity(
                id: 'bcg',
                name: 'BCG',
                recommendedMonth: 0,
                status: false,
                description: 'Vaccin à la naissance',
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('BCG'), findsOneWidget);
    expect(find.text('Mois recommandé : 0'), findsOneWidget);
    expect(find.text('Vaccin à la naissance'), findsOneWidget);
  });

  testWidgets('shows an empty state when no vaccines are scheduled', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: VaccineSchedulePage(repository: _FakeMaternityRepository()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Aucun vaccin prévu pour le moment.'), findsOneWidget);
  });
}

class _FakeMaternityRepository implements MaternityRepository {
  const _FakeMaternityRepository({this.vaccines = const []});

  final List<VaccineEntity> vaccines;

  @override
  Future<List<VaccineEntity>> getVaccinationSchedule() async => vaccines;

  @override
  Future<List<CpnEntity>> getCpnSchedule() async => const [];

  @override
  Future<void> setVaccineCompleted(String vaccineId, bool completed) async {}

  @override
  Future<void> setCpnCompleted(String cpnId, bool completed) async {}

  @override
  Future<void> setVaccineReminder(
    String vaccineId,
    DateTime? reminderAt,
  ) async {}
}
