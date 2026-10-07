# MediGuide

**MediGuide** est une application Flutter qui aide à trouver des centres de santé, consulter des informations d’urgence et suivre des échéances de santé maternelle et infantile. Elle combine Firebase/Cloud Firestore, des données locales et une carte OpenStreetMap.

> [!IMPORTANT]
> MediGuide est un outil d’information et d’orientation. Il ne remplace pas un professionnel de santé, les services d’urgence, ni la vérification directe des horaires, numéros et disponibilités.

## Sommaire

- [Fonctionnalités](#fonctionnalités)
- [Technologies](#technologies)
- [Prérequis](#prérequis)
- [Installation et lancement](#installation-et-lancement)
- [Configuration Firebase](#configuration-firebase)
- [Données et mode hors ligne](#données-et-mode-hors-ligne)
- [Rappels de vaccination sur Android](#rappels-de-vaccination-sur-android)
- [Tests et analyse](#tests-et-analyse)
- [Organisation du code](#organisation-du-code)
- [État et limites connues](#état-et-limites-connues)

## Fonctionnalités

- **Accueil et recherche** : accès aux services prioritaires et recherche par établissement, pays, ville et type.
- **Carte sanitaire** : hôpitaux, cliniques et pharmacies consultés dans Cloud Firestore; marqueurs regroupés lorsque les établissements sont proches. Le fond de carte et les tuiles sont fournis par OpenStreetMap.
- **Détails d’un établissement** : coordonnées disponibles, horaires connus, appel téléphonique si un numéro est renseigné et ouverture d’un itinéraire avec une application compatible.
- **Urgences** : accès rapide aux numéros d’urgence locaux, et aux établissements provenant de Firestore pour un compte connecté. Les établissements et numéros de repli sont embarqués dans l’application.
- **Maternité et santé maternelle** : suivi des tâches; calendrier de vaccinations et consultations prénatales (CPN). Un visiteur conserve sa progression localement; un compte connecté la synchronise avec Firestore.
- **Rappels vaccinaux locaux** : programmation à 09 h 00, heure locale, activation/désactivation depuis Profil et ouverture du calendrier vaccinal au toucher de la notification. Sur Android, les autorisations de notification et d’alarme exacte sont nécessaires.
- **Profil** : identité du compte ou mode visiteur, état de connexion et zone de recherche conservée sur l’appareil.
- **Mode hors ligne partiel** : cache Firestore pour les données déjà consultées, données maternité invitées et informations d’urgence embarquées. Les fonds de carte et les tuiles ne sont pas garantis hors connexion.

Les pays et villes actuellement prévus par le code sont Lomé (Togo), Ouagadougou (Burkina Faso) et Abidjan (Côte d’Ivoire).

## Technologies

| Domaine | Technologie |
| --- | --- |
| Application | Flutter, Dart |
| État et injection | Riverpod |
| Navigation | `go_router` |
| Authentification et données | Firebase Authentication, Cloud Firestore |
| Carte | `flutter_map`, OpenStreetMap, `latlong2`, clusters de marqueurs |
| Préférences locales | `shared_preferences` |
| Notifications locales | `flutter_local_notifications`, `timezone` |
| Tests Firestore | Firebase Emulator Suite et `@firebase/rules-unit-testing` |

## Prérequis

- Flutter et Dart compatibles avec les contraintes de `pubspec.yaml` (`sdk: ^3.13.2`).
- Android Studio et le SDK Android pour construire ou exécuter sur Android.
- Un compte/projet Firebase configuré si l’application doit utiliser l’authentification et les données Firestore.
- Node.js et npm uniquement pour les outils de seeding et les tests des règles Firestore.

La configuration Firebase présente dans le dépôt contient des options pour Android, iOS, macOS, Web et Windows. Linux n’a pas de configuration Firebase dans `lib/firebase_options.dart`. Les permissions natives et la réception des rappels décrites ici concernent Android.

Vérifier l’installation de Flutter avant de commencer :

```powershell
flutter doctor
flutter --version
```

## Installation et lancement

Depuis la racine du dépôt :

```powershell
flutter pub get
flutter run
```

Pour lancer sur un appareil précis, relever son identifiant avec `flutter devices`, puis exécuter :

```powershell
flutter run -d <device-id>
```

Pour produire un APK de développement Android :

```powershell
flutter build apk --debug
```

## Configuration Firebase

Le dépôt contient `lib/firebase_options.dart` et `firebase.json` pour un projet Firebase déjà configuré. Le fichier `.firebaserc` associe l’alias `staging` au projet `mediguide-1d550`. Les valeurs clientes de configuration Firebase identifient l’application; elles ne remplacent pas les règles de sécurité Firestore.

### Authentification

Dans la console Firebase :

1. Ouvrir **Authentication → Sign-in method**.
2. Activer le fournisseur **E-mail/Mot de passe**.
3. Vérifier les domaines autorisés si l’application Web est utilisée.

L’application crée et authentifie des comptes avec e-mail et mot de passe. Les informations de profil du compte sont stockées sous `users/{uid}`.

### Connecter un autre projet Firebase

Installer les outils Firebase si nécessaire, se connecter, puis reconfigurer les plateformes :

```powershell
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
flutterfire configure --project <firebase-project-id>
```

Vérifier ensuite les plateformes générées dans `lib/firebase_options.dart` et la configuration Android produite par FlutterFire. Ne pas ajouter de clé privée de compte de service, de mot de passe ou de fichier de credentials d’administration au dépôt.

### Firestore

Créer une base Cloud Firestore dans le projet Firebase, puis examiner les règles et index du dépôt avant tout déploiement :

- `firestore.rules` — droits d’accès à chaque collection.
- `firestore.indexes.json` — index composites utilisés par les requêtes de centres de santé.

Après revue, les règles et index peuvent être déployés avec Firebase CLI :

```powershell
firebase use staging
firebase deploy --only firestore:rules,firestore:indexes
```

Les règles actuelles réservent la lecture des centres et des références maternité aux utilisateurs connectés. Un visiteur voit les données d’urgence locales et peut utiliser les données maternité invitées, mais n’a pas accès aux collections Firestore protégées.

### Collections utilisées

| Collection / chemin | Contenu | Accès prévu |
| --- | --- | --- |
| `medical_centers/{centerId}` | Établissements, coordonnées, type, horaires et téléphone disponible | Lecture authentifiée; écriture réservée au compte de seeding défini dans les règles |
| `maternity_vaccines/{vaccineId}` | Référentiel des vaccinations | Lecture authentifiée; référentiel non modifiable par l’application |
| `maternity_cpn_schedules/{cpnId}` | Référentiel des consultations prénatales | Lecture authentifiée; référentiel non modifiable par l’application |
| `users/{uid}` | Profil du compte (nom, e-mail, pays et ville) | Propriétaire du compte |
| `users/{uid}/vaccine_progress/{vaccineId}` | Progression et date choisie de rappel du vaccin | Propriétaire du compte |
| `users/{uid}/cpn_progress/{cpnId}` | Progression CPN | Propriétaire du compte |
| `users/{uid}/maternity_tasks/{taskId}` | Tâches de santé maternelle | Propriétaire du compte |

Les documents de `medical_centers` doivent contenir notamment `name`, `nameLower`, `type`, `countryCode`, `country`, `city`, `latitude` et `longitude`. Les coordonnées doivent être numériques; `phone`, `address` et `openingHours` peuvent être absents. Les valeurs `countryCode` prévues actuellement sont `TG`, `BF` et `CI`.

> [!WARNING]
> Dans `firestore.rules`, la fonction `isSeeder()` contient la valeur de remplacement `REMPLACER_PAR_UID_SEEDER`. Avant de déployer une configuration qui utilise le seeding de centres, remplacer cette valeur par l’UID exact du compte autorisé, puis faire relire et tester les règles. Ne jamais autoriser l’écriture publique de `medical_centers`.

### Importer les références maternité

Le référentiel source est `assets/data/maternity_reference.json`. Les comptes invités le lisent directement depuis cet asset. Pour les comptes authentifiés, les collections de référence doivent être importées dans Firestore.

Le script `tools/maternity_seed/import.mjs` affiche par défaut un plan sans écrire de données :

```powershell
Set-Location tools/maternity_seed
npm ci
npm test
npm run seed
```

Pour appliquer l’import, configurer au préalable les identifiants Google Cloud Admin SDK par le mécanisme local approuvé par votre équipe (par exemple Application Default Credentials), puis demander explicitement l’écriture :

```powershell
npm run seed -- --apply
```

L’import utilise des écritures fusionnées (`merge`) dans `maternity_vaccines` et `maternity_cpn_schedules`. Ne lancez `--apply` que sur le projet et l’environnement souhaités.

## Données et mode hors ligne

- **Centres de santé** : les recherches interrogent `medical_centers` dans Firestore. La carte utilise ensuite les coordonnées pour filtrer les établissements proches. Les données de centres ne sont pas téléchargées directement depuis OpenStreetMap par chaque écran; l’application contient un seeder de développement permettant une collecte Overpass pour les villes listées dans le code.
- **Urgences** : les numéros sont intégrés localement, et comprennent des entrées dont la vérification est explicitement marquée. L’affichage d’un hôpital ou d’une pharmacie de garde connectés utilise Firestore; en mode visiteur ou en cas d’erreur réseau récupérable, l’écran utilise les données locales disponibles.
- **Maternité** : les listes de référence invitées viennent de `assets/data/maternity_reference.json`; progression et dates invitées sont locales. Pour un compte authentifié, références et progression sont lues ou écrites dans Firestore.
- **Profil** : la zone de recherche est locale et indépendante du pays du compte. Le cache Firestore est activé pour les données déjà consultées; cela ne garantit pas le chargement initial de données jamais mises en cache.
- **Carte** : l’affichage du fond de carte requiert normalement un accès Internet. OpenStreetMap exige l’attribution visible dans l’application et le respect de sa politique d’utilisation des tuiles.

La disponibilité, l’exactitude et l’actualité des numéros d’urgence, coordonnées, horaires et données d’établissements doivent être vérifiées auprès des sources officielles locales.

## Rappels de vaccination sur Android

Les rappels sont des **notifications locales** sur l’appareil; ils ne sont pas envoyés depuis Firebase. Chaque échéance est enregistrée dans le calendrier métier avant la tentative de programmation de la notification.

Sur Android, le manifeste déclare `POST_NOTIFICATIONS`, `SCHEDULE_EXACT_ALARM`, `RECEIVE_BOOT_COMPLETED` et les receivers nécessaires à la reprogrammation au redémarrage. Au premier rappel, l’utilisateur peut devoir autoriser les notifications et l’accès spécial aux alarmes exactes dans les paramètres Android.

Dans Profil :

- l’option **Rappels de vaccination** est activée par défaut et sa préférence est enregistrée sur l’appareil;
- la désactivation annule les notifications locales sans effacer les dates de rappel sauvegardées;
- la réactivation recharge les échéances futures non terminées et tente de les reprogrammer;
- si une autorisation manque, la date reste visible, mais l’application affiche que la notification n’a pas été programmée.

Un rappel est programmé à 09 h 00, heure locale. Pour valider la livraison réelle, tester sur un appareil ou émulateur Android avec les deux autorisations, application active/en arrière-plan/arrêtée, et après redémarrage. Un test unitaire ou une compilation ne garantit pas qu’un constructeur Android ne retardera pas une alarme selon ses réglages d’économie d’énergie.

## Tests et analyse

Exécuter les tests Flutter :

```powershell
flutter test
```

Analyser le code et construire l’application Android :

```powershell
flutter analyze lib
flutter build apk --debug
```

Les tests des règles Firestore utilisent l’émulateur Firestore. Dans un terminal, démarrer l’émulateur :

```powershell
firebase emulators:start --only firestore --project mediguide-rules-test
```

Dans un second terminal PowerShell :

```powershell
Set-Location tools/firestore_rules_tests
npm ci
$env:FIRESTORE_EMULATOR_HOST = "127.0.0.1:8080"
npm test
```

Les tests couvrent notamment les règles de lecture des référentiels, l’isolation de la progression par UID, les chemins de permission des rappels simulés en test, la navigation par notification et les principaux écrans. Ils ne valident pas la délivrance réelle des notifications Android; celle-ci nécessite le contrôle manuel décrit plus haut.

## Organisation du code

```text
lib/
├── config/                 # Routeur et configuration applicative
├── core/                   # Services, réseau, thème, utilitaires et widgets communs
├── features/
│   ├── auth/               # Connexion, inscription et réinitialisation du mot de passe
│   ├── emergency/          # Numéros et établissements d'urgence
│   ├── health_centers/     # Recherche, carte, données Firestore et modèles
│   ├── home/               # Tableau de bord
│   ├── maternity/          # Calendriers, progression et rappels vaccinaux
│   ├── navigation/         # Coquille et barre de navigation
│   └── user_profile/       # Profil, zone locale et préférence des rappels
└── main.dart               # Initialisation Firebase, notifications et application

assets/data/                # Référentiels locaux JSON
android/                    # Configuration native Android
tools/                      # Import de référentiels et tests de règles
test/                       # Tests unitaires et widget Flutter
firestore.rules             # Règles de sécurité Firestore
firestore.indexes.json      # Index Firestore
```

Les fonctionnalités suivent généralement une séparation `presentation/`, `domain/` et `data/` : widgets et contrôleurs d’un côté, contrats et entités métier au centre, sources de données et dépôts de l’autre.

## État et limites connues

- Les lieux supportés sont limités aux trois villes indiquées plus haut; la couverture dépend du contenu présent dans Firestore.
- Les numéros d’urgence ne sont pas tous marqués vérifiés. L’appareil ou le réseau téléphonique peut aussi affecter la possibilité de composer un numéro.
- Les centres et horaires peuvent être incomplets ou obsolètes; les données d’OpenStreetMap dépendent de leur contribution et de l’import effectué.
- La persistance Firestore permet de relire des données mises en cache, mais les lectures et écritures nécessitant un serveur peuvent échouer hors ligne.
- Les rappels locaux ne sont pas une garantie de réception : l’utilisateur peut refuser ou révoquer les autorisations, et le système ou le constructeur peut retarder une alarme.
- L’application n’effectue pas de diagnostic médical et ne remplace pas les services d’urgence.
