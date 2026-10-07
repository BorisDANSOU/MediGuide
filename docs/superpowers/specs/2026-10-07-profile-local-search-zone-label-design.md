# Libellé de la zone de recherche locale

## Objectif

Éviter que les utilisateurs confondent le pays/ville de recherche enregistré sur leur appareil avec les informations de localisation du compte Firestore.

## Comportement

Sur l'écran Profil, renommer la carte actuelle « Pays et ville » en « Zone de recherche » et ajouter une précision visible indiquant que ce choix est enregistré sur cet appareil et indépendant du pays associé au compte. Conserver les valeurs pays/ville existantes, le sélecteur, le stockage `SharedPreferences` et le comportement de connexion inchangés.

## Hors périmètre

- Ne pas synchroniser les changements locaux vers Firestore.
- Ne pas supprimer ni modifier les champs `country` et `city` du compte Firestore.
- Ne pas modifier l'import de la zone du compte lors de la connexion.
- Ne pas changer les fonctions de sélection de zone ni le routage.

## Validation

- Un test widget vérifie le nouveau titre et la précision du stockage local.
- Un test existant ou étendu vérifie que la modification du pays continue de mettre à jour la zone locale affichée.
- Exécuter les tests ciblés du Profil et `flutter analyze lib`.

## Éléments vérifiés dans le code

- `lib/features/user_profile/presentation/pages/profile_page.dart`
- `lib/features/user_profile/presentation/widgets/country_picker_sheet.dart`
- `lib/features/user_profile/data/datasources/user_local_datasource.dart`
- `lib/features/auth/presentation/pages/auth_page.dart`
