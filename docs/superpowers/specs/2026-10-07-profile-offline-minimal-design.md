# Profil et mode hors-ligne — périmètre minimal

## Objectif

Rendre l'écran Profil utile et cohérent avec les fonctions déjà présentes, sans reproduire les sections de la maquette qui n'ont pas de données ou de réglages réels derrière elles.

## Périmètre

- Afficher l'identité Firebase de l'utilisateur connecté; en l'absence de session, afficher clairement le mode visiteur.
- Garder la zone de recherche pays/ville existante et son sélecteur, avec stockage local via `SharedPreferences`.
- Afficher l'état réseau à partir de `connectivity_plus`, et expliquer que les données déjà chargées peuvent rester disponibles hors ligne.
- Pour un utilisateur connecté, proposer une déconnexion Firebase avec confirmation, puis naviguer vers la route d'authentification. Le mode visiteur ne montre pas ce bouton.
- Garder l'interface sobre et réutiliser les composants et le thème existants.

## Hors périmètre

Ne pas ajouter de données médicales d'urgence, de couverture CMU, de contact ICE, de jauge de cache, de téléchargement de régions, de préférences linguistiques/énergie/rappels, ni d'assistance téléphonique: ces éléments ne sont pas actuellement configurés comme fonctions du profil.

## Architecture et comportement

`ProfilePage` observe `authSessionProvider` et `userProfileControllerProvider`. Le choix de zone continue d'utiliser `CountryPickerSheet`. L'état de connectivité est présenté au moyen du mécanisme `OfflineBanner` existant ou d'une présentation équivalente alimentée par `connectivity_plus`; il ne prétend pas mesurer l'accès Internet ni la taille du cache. La déconnexion passe par `AuthSession.signOut()`; une erreur est affichée explicitement et ne doit pas présenter la déconnexion comme réussie.

## Validation

- Tests widget pour utilisateur connecté et visiteur.
- Vérifier l'ouverture et l'annulation de la confirmation de déconnexion, puis la navigation après confirmation.
- Vérifier l'affichage et le changement de la zone de recherche.
- Vérifier le statut hors ligne avec le flux de connectivité simulé.
- Exécuter les tests du profil et `flutter analyze lib`.

## Éléments vérifiés dans le code

- `lib/features/user_profile/presentation/pages/profile_page.dart`
- `lib/features/user_profile/presentation/controllers/user_profile_controller.dart`
- `lib/features/user_profile/presentation/widgets/country_picker_sheet.dart`
- `lib/features/auth/presentation/controllers/auth_providers.dart`
- `lib/core/widgets/offline_banner.dart`
- `lib/config/routes/app_routes.dart`
