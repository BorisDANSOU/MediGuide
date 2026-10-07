# Libellé de la zone de recherche locale

## Objectif

Éviter que les utilisateurs confondent le pays/ville de recherche enregistré sur leur appareil avec les informations de localisation du compte Firestore.

## Comportement

Sur l'écran Profil, renommer la carte actuelle « Pays et ville » en « Zone de recherche » et ajouter une précision visible indiquant que ce choix est enregistré sur cet appareil et indépendant du pays associé au compte. Conserver les valeurs pays/ville existantes, le sélecteur et le stockage `SharedPreferences`.

Lors d'une connexion ou d'une inscription, utiliser le pays du compte pour initialiser la zone locale uniquement si aucune zone n'a encore été enregistrée sur cet appareil. Si l'utilisateur a déjà choisi une zone locale, ne pas l'écraser avec le pays du compte. Cette règle fournit un défaut utile au premier lancement et conserve le choix local aux connexions ultérieures.

## Hors périmètre

- Ne pas synchroniser les changements locaux vers Firestore.
- Ne pas supprimer ni modifier les champs `country` et `city` du compte Firestore.
- Ne pas synchroniser les changements de zone depuis Profil vers Firestore.
- Ne pas changer les fonctions de sélection de zone ni le routage.

## Validation

- Un test widget vérifie le nouveau titre et la précision du stockage local.
- Un test vérifie qu'une zone locale existante survit à une connexion ultérieure.
- Un test vérifie que le pays du compte initialise la zone si aucune préférence locale n'existe.
- Un test existant ou étendu vérifie que la modification du pays continue de mettre à jour la zone locale affichée.
- Exécuter les tests ciblés du Profil et `flutter analyze lib`.

## Éléments vérifiés dans le code

- `lib/features/user_profile/presentation/pages/profile_page.dart`
- `lib/features/user_profile/presentation/widgets/country_picker_sheet.dart`
- `lib/features/user_profile/data/datasources/user_local_datasource.dart`
- `lib/features/auth/presentation/pages/auth_page.dart`
