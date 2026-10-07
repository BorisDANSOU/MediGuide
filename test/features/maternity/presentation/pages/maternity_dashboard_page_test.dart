import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediguid/features/auth/domain/entities/app_user.dart';
import 'package:mediguid/features/auth/presentation/controllers/auth_providers.dart';
import 'package:mediguid/features/maternity/domain/entities/cpn_entity.dart';
import 'package:mediguid/features/maternity/domain/entities/health_task_entity.dart';
import 'package:mediguid/features/maternity/domain/entities/vaccine_entity.dart';
import 'package:mediguid/features/maternity/domain/repositories/health_tasks_repository.dart';
import 'package:mediguid/features/maternity/domain/repositories/maternity_repository.dart';
import 'package:mediguid/features/maternity/presentation/pages/maternity_dashboard_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('renders the maternity dashboard mockup sections', (
    WidgetTester tester,
  ) async {
    await _pumpDashboard(tester);
    await tester.pumpAndSettle();

    expect(find.text('Espace Santé Maternelle'), findsOneWidget);
    expect(find.text('PROTOCOLE RÉACTIF OBSTÉTRICAL'), findsOneWidget);
    expect(find.text('Prochaine consultation recommandée'), findsOneWidget);
    expect(
      find.text('Recommandation du calendrier — aucun rendez-vous confirmé.'),
      findsOneWidget,
    );
    expect(find.text('Semaine recommandée : 26'), findsNWidgets(2));
    expect(find.text('28e SA'), findsNothing);
    expect(find.text('T3 • Trimestre Vital'), findsNothing);
    expect(find.textContaining('14 Nov. 2025'), findsNothing);
    expect(find.text('Dans 4 jours'), findsNothing);
    expect(find.textContaining('Jeudi 18 Septembre'), findsNothing);
    expect(find.textContaining('Centre Médical Urbain'), findsNothing);
    expect(find.textContaining('Dr. Konan'), findsNothing);
    expect(find.text('Confirmer présence'), findsNothing);
    expect(find.text('Itinéraire'), findsNothing);
    expect(find.text('Échéances & Examens Recommandés'), findsOneWidget);
    expect(find.text('Repères & Conseils Validés'), findsOneWidget);
    expect(find.text('Ligne d’écoute Maternité'), findsOneWidget);
    expect(find.byType(Image), findsNWidgets(3));
    expect(find.textContaining('Dossier suivi :'), findsNothing);
    expect(find.textContaining('Awa K.'), findsNothing);
    expect(find.textContaining('28 ans'), findsNothing);
    expect(find.textContaining('MG-9821'), findsNothing);
  });

  testWidgets('renders mapped task titles and declared completion state', (
    WidgetTester tester,
  ) async {
    await _pumpDashboard(
      tester,
      healthTasks: [
        _healthTask('echo3', title: 'Ultrasound task title'),
        _healthTask('blood2', title: 'Blood task title', isCompleted: true),
        _healthTask('vat1', title: 'VAT first dose'),
        _healthTask('vat2', title: 'VAT second dose'),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('Ultrasound task title'), findsOneWidget);
    expect(find.text('Blood task title'), findsOneWidget);
    expect(find.text('VAT first dose'), findsOneWidget);
    expect(find.text('VAT second dose'), findsNothing);
    expect(find.text('À suivre'), findsNWidgets(2));
    expect(find.text('Déclaré fait'), findsOneWidget);
    expect(find.text('Hémoglobine 11.8 g/dL'), findsNothing);
    expect(find.text('3 centres équipés à proximité'), findsNothing);
    expect(find.text('Effectué le 20 Août'), findsNothing);
    expect(find.text('Réserver →'), findsNothing);
    expect(find.text('PDF'), findsNothing);
    expect(find.textContaining('2026-01-01'), findsNothing);
    expect(find.textContaining('2026-01-02'), findsNothing);
  });

  testWidgets('selects VAT doses in order and keeps the last completed dose', (
    WidgetTester tester,
  ) async {
    final scenarios = [
      (
        tasks: [
          _healthTask('vat1', title: 'VAT 1'),
          _healthTask('vat2', title: 'VAT 2'),
        ],
        expected: 'VAT 1',
        status: 'À suivre',
      ),
      (
        tasks: [
          _healthTask('vat1', title: 'VAT 1', isCompleted: true),
          _healthTask('vat2', title: 'VAT 2'),
        ],
        expected: 'VAT 2',
        status: 'À suivre',
      ),
      (
        tasks: [
          _healthTask('vat1', title: 'VAT 1', isCompleted: true),
          _healthTask('vat2', title: 'VAT 2', isCompleted: true),
        ],
        expected: 'VAT 2',
        status: 'Déclaré fait',
      ),
      (
        tasks: [_healthTask('vat2', title: 'VAT 2 only')],
        expected: 'VAT 2 only',
        status: 'À suivre',
      ),
      (
        tasks: [_healthTask('vat1', title: 'VAT 1 only', isCompleted: true)],
        expected: 'VAT 1 only',
        status: 'Déclaré fait',
      ),
    ];

    for (final scenario in scenarios) {
      await _pumpDashboard(tester, healthTasks: scenario.tasks);
      await tester.pumpAndSettle();
      expect(find.text(scenario.expected), findsOneWidget);
      expect(find.text(scenario.status), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('omits cards when their mapped tasks are missing', (
    WidgetTester tester,
  ) async {
    await _pumpDashboard(
      tester,
      healthTasks: [_healthTask('cpn1', title: 'Unrelated task')],
    );
    await tester.pumpAndSettle();

    expect(find.text('Unrelated task'), findsNothing);
    expect(find.text('3ème Échographie obstétricale'), findsNothing);
    expect(find.text('Bilan biologique T2 & Glycémie'), findsNothing);
    expect(find.text('Vaccination antitétanique (VAT)'), findsNothing);
  });

  testWidgets('hides cards while health tasks are loading', (
    WidgetTester tester,
  ) async {
    final completer = Completer<List<HealthTaskEntity>>();
    final repository = _FakeHealthTasksRepository(completer: completer);
    await _pumpDashboard(tester, healthTasksRepository: repository);
    await tester.pump(const Duration(milliseconds: 150));

    expect(find.text('Ultrasound task title'), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    completer.complete([_healthTask('echo3', title: 'Ultrasound task title')]);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Ultrasound task title'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });

  testWidgets('shows task loading errors and retries successfully', (
    WidgetTester tester,
  ) async {
    final repository = _FakeHealthTasksRepository(
      loadError: StateError('offline'),
    );
    await _pumpDashboard(tester, healthTasksRepository: repository);
    await tester.pumpAndSettle();

    expect(find.textContaining('offline'), findsOneWidget);
    expect(find.text('Réessayer'), findsOneWidget);
    expect(find.text('Ultrasound task title'), findsNothing);

    repository
      ..loadError = null
      ..tasks = [_healthTask('echo3', title: 'Ultrasound task title')];
    await tester.ensureVisible(find.text('Réessayer'));
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();
    expect(find.text('Ultrasound task title'), findsOneWidget);
  });

  testWidgets('card and Tout voir actions open the health-task list', (
    WidgetTester tester,
  ) async {
    await _pumpDashboard(
      tester,
      healthTasks: [_healthTask('echo3', title: 'Ultrasound task title')],
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Voir le suivi'));
    await tester.tap(find.text('Voir le suivi'));
    await tester.pumpAndSettle();
    expect(find.text('Suivi de Santé'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Tout voir'));
    await tester.tap(find.text('Tout voir'));
    await tester.pumpAndSettle();
    expect(find.text('Suivi de Santé'), findsOneWidget);
  });

  testWidgets('switches between pregnancy and baby schedules', (
    WidgetTester tester,
  ) async {
    await _pumpDashboard(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mon Bébé (0–24 mois)'));
    await tester.pumpAndSettle();
    expect(find.text('BCG'), findsOneWidget);

    await tester.tap(find.text('Ma Grossesse (En cours)'));
    await tester.pumpAndSettle();
    expect(find.text('Prochaine consultation recommandée'), findsOneWidget);
  });

  testWidgets('shows the first incomplete CPN and a neutral completed state', (
    WidgetTester tester,
  ) async {
    const schedules = [
      CpnEntity(id: 'cpn1', name: 'CPN 1', week: 12, completed: true),
      CpnEntity(id: 'cpn2', name: 'CPN 2', week: 20, completed: false),
      CpnEntity(id: 'cpn3', name: 'CPN 3', week: 26, completed: false),
    ];
    await _pumpDashboard(tester, cpnSchedules: schedules);
    await tester.pumpAndSettle();

    final recommendation = find.ancestor(
      of: find.text(
        'Recommandation du calendrier — aucun rendez-vous confirmé.',
      ),
      matching: find.byType(Card),
    );
    expect(
      find.descendant(of: recommendation, matching: find.text('CPN 2')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: recommendation,
        matching: find.text('Semaine recommandée : 20'),
      ),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await _pumpDashboard(
      tester,
      cpnSchedules: [
        for (final schedule in schedules)
          CpnEntity(
            id: schedule.id,
            name: schedule.name,
            week: schedule.week,
            completed: true,
          ),
      ],
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Aucune consultation CPN à venir dans le calendrier.'),
      findsOneWidget,
    );
    expect(
      find.text('Recommandation du calendrier — aucun rendez-vous confirmé.'),
      findsNothing,
    );
  });

  testWidgets("shows the actual signed-in user's name without demo details", (
    WidgetTester tester,
  ) async {
    const user = AppUser(
      id: 'account-1',
      fullName: 'Mariam Traoré',
      email: 'mariam@example.com',
    );
    await _pumpDashboard(tester, user: user);
    await tester.pumpAndSettle();

    expect(find.text('Dossier suivi : Mariam Traoré'), findsOneWidget);
    expect(find.textContaining('Awa K.'), findsNothing);
    expect(find.textContaining('28 ans'), findsNothing);
    expect(find.textContaining('MG-9821'), findsNothing);
  });

  testWidgets('hides dossier line when signed-in name is blank', (
    WidgetTester tester,
  ) async {
    const user = AppUser(id: 'account-1', fullName: '   ', email: 'a@b.test');
    await _pumpDashboard(tester, user: user);
    await tester.pumpAndSettle();

    expect(find.textContaining('Dossier suivi :'), findsNothing);
  });
}

Future<void> _pumpDashboard(
  WidgetTester tester, {
  AppUser? user,
  List<HealthTaskEntity> healthTasks = const [],
  HealthTasksRepository? healthTasksRepository,
  List<CpnEntity> cpnSchedules = const [
    CpnEntity(id: 'cpn3', name: 'CPN 3', week: 26, completed: false),
  ],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authSessionProvider.overrideWith(() => _TestAuthSession(user)),
      ],
      child: MaterialApp(
        home: MaternityDashboardPage(
          repository: _FakeMaternityRepository(cpnSchedules: cpnSchedules),
          healthTasksRepository:
              healthTasksRepository ??
              _FakeHealthTasksRepository(tasks: healthTasks),
        ),
      ),
    ),
  );
}

class _TestAuthSession extends AuthSession {
  _TestAuthSession(this.user);

  final AppUser? user;

  @override
  AppUser? build() => user;
}

class _FakeMaternityRepository implements MaternityRepository {
  const _FakeMaternityRepository({
    this.cpnSchedules = const [
      CpnEntity(id: 'cpn3', name: 'CPN 3', week: 26, completed: false),
    ],
  });

  final List<CpnEntity> cpnSchedules;

  @override
  Future<List<VaccineEntity>> getVaccinationSchedule() async => const [
    VaccineEntity(id: 'bcg', name: 'BCG', recommendedMonth: 0, status: false),
  ];

  @override
  Future<List<CpnEntity>> getCpnSchedule() async => cpnSchedules;

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

class _FakeHealthTasksRepository implements HealthTasksRepository {
  _FakeHealthTasksRepository({
    this.tasks = const [],
    this.loadError,
    this.completer,
  });

  List<HealthTaskEntity> tasks;
  Object? loadError;
  final Completer<List<HealthTaskEntity>>? completer;

  @override
  Future<List<HealthTaskEntity>> getHealthTasks() async {
    if (completer != null) return completer!.future;
    final error = loadError;
    if (error != null) throw error;
    return tasks;
  }

  @override
  Future<HealthTaskEntity> completeTask(String taskId) async {
    final index = tasks.indexWhere((task) => task.id == taskId);
    if (index == -1) throw StateError('Unknown task: $taskId');
    final updated = tasks[index].copyWith(isCompleted: true);
    tasks[index] = updated;
    return updated;
  }

  @override
  Future<List<HealthTaskEntity>> getTasksByCategory(
    HealthTaskCategory category,
  ) async => tasks.where((task) => task.category == category).toList();

  @override
  Future<List<HealthTaskEntity>> getUrgentTasks() async => tasks
      .where(
        (task) =>
            (task.priority == HealthTaskPriority.urgent ||
                task.priority == HealthTaskPriority.high) &&
            !task.isCompleted,
      )
      .toList();

  @override
  Future<List<HealthTaskEntity>> getOverdueTasks() async => tasks
      .where(
        (task) => task.dueDate.isBefore(DateTime.now()) && !task.isCompleted,
      )
      .toList();
}

HealthTaskEntity _healthTask(
  String id, {
  String? title,
  bool isCompleted = false,
}) => HealthTaskEntity(
  id: id,
  title: title ?? id,
  description: 'Test task description',
  category: id.startsWith('vat')
      ? HealthTaskCategory.vaccination
      : HealthTaskCategory.examination,
  priority: HealthTaskPriority.medium,
  dueDate: DateTime(2026, 1, 1),
  isCompleted: isCompleted,
  completedDate: isCompleted ? DateTime(2026, 1, 2) : null,
);
