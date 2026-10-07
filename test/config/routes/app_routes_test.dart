import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediguid/config/routes/app_routes.dart';
import 'package:mediguid/core/services/notification_service.dart';
import 'package:mediguid/features/auth/presentation/controllers/auth_providers.dart';
import 'package:mediguid/features/user_profile/presentation/controllers/user_profile_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../fakes/fake_auth_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('notification navigation opens the vaccine schedule', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final router = createAppRouter(initialLocation: AppRoutes.maternity);
    final notifications = NotificationService(
      initialize: () async {},
      readLaunchPayload: () async => 'vaccine_reminder:bcg',
    )..setNotificationTapHandler((_) => navigateToVaccineSchedule(router));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await notifications.initialize();
    await tester.pumpAndSettle();

    await notifications.handleInitialNotificationTap();
    await tester.pumpAndSettle();

    expect(find.text('Calendrier vaccinal'), findsOneWidget);

    router.go(AppRoutes.maternity);
    await tester.pumpAndSettle();
    notifications.handleNotificationTap('vaccine_reminder:bcg');
    await tester.pumpAndSettle();

    expect(find.text('Calendrier vaccinal'), findsOneWidget);
  });
}
