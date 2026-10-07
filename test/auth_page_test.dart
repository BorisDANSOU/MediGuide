import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mediguid/config/routes/app_routes.dart';
import 'package:mediguid/features/auth/data/repositories/firebase_auth_error_messages.dart';
import 'package:mediguid/features/auth/domain/entities/app_user.dart';

import 'fakes/fake_auth_repository.dart';
import 'helpers.dart';

Future<void> _tap(WidgetTester tester, String text) =>
    tapVisible(tester, find.text(text).last);

Future<void> _fillLogin(WidgetTester tester, String email, String pwd) async {
  await tester.enterText(find.byType(TextFormField).at(0), email);
  await tester.enterText(find.byType(TextFormField).at(1), pwd);
}

void main() {
  testWidgets('Connexion : champs vides refusés', (tester) async {
    await pumpApp(tester, location: AppRoutes.auth);
    await _tap(tester, 'Se connecter');

    expect(find.text('Saisissez votre adresse e-mail.'), findsOneWidget);
    expect(find.text('Saisissez votre mot de passe.'), findsOneWidget);
  });

  testWidgets('Connexion : identifiants incorrects', (tester) async {
    await pumpApp(tester, location: AppRoutes.auth);
    await _fillLogin(tester, FakeAuthRepository.knownEmail, 'mauvais-mdp');
    await _tap(tester, 'Se connecter');

    expect(find.text('E-mail ou mot de passe incorrect.'), findsOneWidget);
  });

  testWidgets('Connexion : conserve la zone locale déjà choisie', (
    tester,
  ) async {
    await pumpApp(
      tester,
      location: AppRoutes.auth,
      country: "Côte d'Ivoire",
      city: 'Abidjan',
    );
    await _fillLogin(
      tester,
      FakeAuthRepository.knownEmail,
      FakeAuthRepository.knownPassword,
    );
    await _tap(tester, 'Se connecter');

    expect(find.text('Bonjour, Awa 👋'), findsOneWidget);
    await _tap(tester, 'Profil');
    expect(find.textContaining("Abidjan, Côte d'Ivoire"), findsWidgets);
    expect(find.text('Se connecter'), findsNothing);
  });

  testWidgets(
    'Connexion : initialise la zone depuis le compte si aucune zone locale',
    (tester) async {
      await pumpApp(
        tester,
        location: AppRoutes.auth,
        saveInitialProfile: false,
      );
      await _fillLogin(
        tester,
        FakeAuthRepository.knownEmail,
        FakeAuthRepository.knownPassword,
      );
      await _tap(tester, 'Se connecter');

      expect(find.text('Bonjour, Awa 👋'), findsOneWidget);
      await _tap(tester, 'Profil');
      expect(find.textContaining('Ouagadougou, Burkina Faso'), findsWidgets);
    },
  );

  testWidgets('Mot de passe oublié : envoie le lien à l’e-mail saisi', (
    tester,
  ) async {
    final auth = FakeAuthRepository();
    await pumpApp(tester, location: AppRoutes.auth, auth: auth);

    await _tap(tester, 'Mot de passe oublié ?');
    expect(find.textContaining('Saisissez d’abord votre e-mail'), findsWidgets);
    expect(auth.resetEmails, isEmpty);

    await tester.enterText(find.byType(TextFormField).at(0), 'awa@exemple.bf');
    await _tap(tester, 'Mot de passe oublié ?');
    expect(auth.resetEmails, ['awa@exemple.bf']);
    expect(find.textContaining('e-mail de réinitialisation'), findsOneWidget);
  });

  testWidgets('Inscription : pays choisi dans la liste déroulante', (
    tester,
  ) async {
    await pumpApp(tester, location: AppRoutes.auth, saveInitialProfile: false);
    await _tap(tester, 'Créer un compte');

    // Les pays ne sont pas affichés tant que la liste n'est pas ouverte.
    expect(find.text("Côte d'Ivoire"), findsNothing);

    await tester.enterText(find.byType(TextFormField).at(0), 'Koffi Amavi');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'koffi@exemple.ci',
    );
    await tapVisible(tester, find.byType(DropdownButtonFormField<String>));
    await tester.tap(find.text("Côte d'Ivoire").last);
    await tester.pumpAndSettle();
    expect(find.text('Abidjan'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(2), 'motdepasse1');
    await tester.enterText(find.byType(TextFormField).at(3), 'motdepasse2');
    await _tap(tester, 'Créer mon compte');
    expect(
      find.text('Les deux mots de passe ne sont pas identiques.'),
      findsOneWidget,
    );
    expect(
      find.text('Acceptez les conditions pour continuer.'),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextFormField).at(3), 'motdepasse1');
    await tapVisible(tester, find.byType(Checkbox));
    await _tap(tester, 'Créer mon compte');

    expect(find.text('Bonjour, Koffi 👋'), findsOneWidget);
    await _tap(tester, 'Profil');
    expect(find.textContaining("Abidjan, Côte d'Ivoire"), findsWidgets);
  });

  testWidgets('Inscription : pays obligatoire', (tester) async {
    await pumpApp(tester, location: AppRoutes.auth);
    await _tap(tester, 'Créer un compte');
    await _tap(tester, 'Créer mon compte');

    expect(find.text('Choisissez votre pays.'), findsOneWidget);
  });

  testWidgets('Session Firebase existante : accueil avec le prénom', (
    tester,
  ) async {
    await pumpApp(
      tester,
      location: AppRoutes.home,
      auth: FakeAuthRepository(
        signedIn: const AppUser(id: 'a', fullName: 'Awa O.', email: 'a@b.bf'),
      ),
    );

    expect(find.text('Bonjour, Awa 👋'), findsOneWidget);
    expect(find.text('Se connecter'), findsNothing);
  });

  testWidgets('« Continuer sans compte » ouvre l’accueil', (tester) async {
    await pumpApp(tester, location: AppRoutes.auth);
    await _tap(tester, 'Continuer sans compte');

    expect(find.text('Urgence vitale ?'), findsOneWidget);
  });

  testWidgets('« Accès urgence express » ouvre les urgences dans la coquille', (
    tester,
  ) async {
    await pumpApp(tester, location: AppRoutes.auth);
    await _tap(tester, 'Accès urgence express');

    expect(find.text('Services nationaux prioritaires'), findsOneWidget);
    expect(find.text('Se connecter'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  test('Messages d’erreur Firebase traduits', () {
    expect(
      authErrorMessage('email-already-in-use'),
      'Un compte existe déjà avec cet e-mail.',
    );
    expect(
      authErrorMessage('invalid-credential'),
      'E-mail ou mot de passe incorrect.',
    );
    expect(
      authErrorMessage('operation-not-allowed'),
      contains('pas encore activée'),
    );
    expect(authErrorMessage('code-inconnu'), contains('Réessayez'));
  });

  for (final size in testSizes) {
    testWidgets('Inscription sans débordement en ${size.width.toInt()} px', (
      tester,
    ) async {
      setScreen(tester, size);
      await pumpApp(tester, location: AppRoutes.auth);
      await _tap(tester, 'Créer un compte');
      await expectNoOverflowWhileScrolling(tester);
    });
  }

  testWidgets('Connexion sans débordement avec texte ×1,5 en 360 px', (
    tester,
  ) async {
    setScreen(tester, const Size(360, 780), textScale: 1.5);
    await pumpApp(tester, location: AppRoutes.auth);
    await expectNoOverflowWhileScrolling(tester);
  });
}
