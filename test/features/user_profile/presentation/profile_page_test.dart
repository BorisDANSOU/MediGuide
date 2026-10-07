import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediguid/config/routes/app_routes.dart';
import 'package:mediguid/core/services/notification_service.dart';
import 'package:mediguid/features/auth/domain/entities/app_user.dart';

import '../../../fakes/fake_auth_repository.dart';
import '../../../helpers.dart';

const _connectivityMethodChannel = MethodChannel(
  'dev.fluttercommunity.plus/connectivity',
);
const _connectivityEventChannel = EventChannel(
  'dev.fluttercommunity.plus/connectivity_status',
);

class _SignOutAuthRepository extends FakeAuthRepository {
  _SignOutAuthRepository({super.signedIn, this.signOutError});

  final Object? signOutError;
  int signOutCalls = 0;

  @override
  Future<void> signOut() async {
    signOutCalls++;
    if (signOutError case final error?) throw error;
    await super.signOut();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      _connectivityMethodChannel,
      (call) async => ['none'],
    );
    messenger.setMockStreamHandler(
      _connectivityEventChannel,
      MockStreamHandler.inline(
        onListen: (_, events) => events.success(['none']),
      ),
    );
  });

  tearDown(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(_connectivityMethodChannel, null);
    messenger.setMockStreamHandler(_connectivityEventChannel, null);
  });

  testWidgets('affiche le profil authentifié et le statut hors ligne', (
    tester,
  ) async {
    const user = AppUser(
      id: 'user-1',
      fullName: 'Awa Ouédraogo',
      email: 'awa@example.com',
    );
    await pumpApp(
      tester,
      location: AppRoutes.profile,
      auth: FakeAuthRepository(signedIn: user),
    );

    expect(find.text('Awa Ouédraogo'), findsOneWidget);
    expect(find.text('awa@example.com'), findsOneWidget);
    expect(find.text('Mode visiteur'), findsNothing);
    expect(find.text('Déconnexion'), findsOneWidget);
    expect(find.text('Zone de recherche'), findsOneWidget);
    expect(
      find.textContaining(
        'Enregistrée sur cet appareil, indépendamment du pays du compte.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Mode hors-ligne : les données déjà consultées restent disponibles.',
      ),
      findsOneWidget,
    );
    expect(
      tester
          .widget<SwitchListTile>(
            find.byKey(const ValueKey('vaccine-reminders-switch')),
          )
          .value,
      isTrue,
    );
  });

  testWidgets('désactive les rappels locaux depuis le profil', (tester) async {
    var cancelCount = 0;
    final notifications = NotificationService(
      cancelAll: () async => cancelCount++,
    );
    await pumpApp(
      tester,
      location: AppRoutes.profile,
      notificationService: notifications,
    );

    await tester.tap(find.byKey(const ValueKey('vaccine-reminders-switch')));
    await tester.pumpAndSettle();

    expect(cancelCount, 1);
    expect(
      tester
          .widget<SwitchListTile>(
            find.byKey(const ValueKey('vaccine-reminders-switch')),
          )
          .value,
      isFalse,
    );
  });

  testWidgets('affiche le mode visiteur sans action de déconnexion', (
    tester,
  ) async {
    await pumpApp(tester, location: AppRoutes.profile);

    expect(find.text('Mode visiteur'), findsOneWidget);
    expect(find.text('Déconnexion'), findsNothing);
  });

  testWidgets('l’en-tête reste visible sur écran étroit avec texte agrandi', (
    tester,
  ) async {
    const city = 'Très longue ville de démonstration';
    const country = 'Pays avec un nom particulièrement long';
    setScreen(tester, const Size(240, 640), textScale: 1.5);
    await pumpApp(
      tester,
      location: AppRoutes.profile,
      city: city,
      country: country,
      auth: FakeAuthRepository(
        signedIn: const AppUser(
          id: 'user-long-name',
          fullName: 'Amavi Koffi avec un nom complet très long',
          email: 'adresse-courriel-tres-longue@example.com',
        ),
      ),
    );

    await expectNoOverflowWhileScrolling(tester);

    expect(find.textContaining('$city, $country'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('annuler la confirmation ne déconnecte pas', (tester) async {
    final auth = _SignOutAuthRepository(
      signedIn: const AppUser(
        id: 'user-1',
        fullName: 'Awa Ouédraogo',
        email: 'awa@example.com',
      ),
    );
    await pumpApp(tester, location: AppRoutes.profile, auth: auth);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Déconnexion'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();

    expect(auth.signOutCalls, 0);
    expect(find.text('Profil'), findsWidgets);
  });

  testWidgets('confirmer la déconnexion conduit à la page de connexion', (
    tester,
  ) async {
    final auth = _SignOutAuthRepository(
      signedIn: const AppUser(
        id: 'user-1',
        fullName: 'Awa Ouédraogo',
        email: 'awa@example.com',
      ),
    );
    await pumpApp(tester, location: AppRoutes.profile, auth: auth);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Déconnexion'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Déconnexion'));
    await tester.pumpAndSettle();

    expect(auth.signOutCalls, 1);
    expect(find.text('Profil'), findsNothing);
    expect(find.text('Connexion'), findsOneWidget);
  });

  testWidgets('affiche l’erreur et reste sur le profil si sign-out échoue', (
    tester,
  ) async {
    final auth = _SignOutAuthRepository(
      signedIn: const AppUser(
        id: 'user-1',
        fullName: 'Awa Ouédraogo',
        email: 'awa@example.com',
      ),
      signOutError: const AuthFailure('Session indisponible.'),
    );
    await pumpApp(tester, location: AppRoutes.profile, auth: auth);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Déconnexion'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Déconnexion'));
    await tester.pumpAndSettle();

    expect(find.text('Session indisponible.'), findsOneWidget);
    expect(find.text('Profil'), findsWidgets);
    expect(find.text('Connexion'), findsNothing);
  });

  testWidgets('la zone de recherche continue de pouvoir changer de pays', (
    tester,
  ) async {
    await pumpApp(tester, location: AppRoutes.profile);

    expect(find.textContaining('Ouagadougou, Burkina Faso'), findsWidgets);
    await tester.tap(find.text('Zone de recherche'));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Côte d'Ivoire"));
    await tester.pumpAndSettle();

    expect(find.textContaining("Abidjan, Côte d'Ivoire"), findsWidgets);
  });
}
