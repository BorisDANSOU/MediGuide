---
goal: Fiabiliser les rappels de vaccination Android et leur gestion depuis Profil
version: 1.0
date_created: 2026-10-07
last_updated: 2026-10-07
owner: MediGuide
status: 'In progress'
tags: [feature, notifications, android, profile]
---

# Introduction

![Status: In progress](https://img.shields.io/badge/status-In%20progress-yellow)

Ce plan met en œuvre les rappels de vaccination précis à 09 h 00, la navigation vers le calendrier vaccinal après un tap, et un réglage local global dans Profil qui annule ou restaure les rappels sans perdre les dates enregistrées.

## 1. Requirements & Constraints

- **REQ-001**: Un rappel de vaccin est planifié à 09 h 00, heure locale, à la date sélectionnée.
- **REQ-002**: Un tap sur une notification ouvre `AppRoutes.vaccines`, que l'application soit active, en arrière-plan ou démarrée par la notification.
- **REQ-003**: Profil affiche un interrupteur global « Rappels de vaccination », actif par défaut et persisté dans `SharedPreferences` sur l'appareil courant.
- **REQ-004**: Désactiver les rappels annule les notifications locales, sans effacer les échéances de vaccin conservées dans Firestore ou dans le dépôt invité local.
- **REQ-005**: Réactiver les rappels recharge le calendrier vaccinal du compte actif ou du mode invité et reprogramme chaque échéance future des vaccins non terminés.
- **REQ-006**: Une échéance enregistrée lorsque le réglage est désactivé reste visible comme date, avec une indication explicite qu'aucune notification n'est active.
- **REQ-007**: Calculer l'identifiant natif en FNV-1a 32 bits sur les octets UTF-8 de `vaccineId`, puis appliquer `& 0x7fffffff`; remplacer le résultat zéro par `1`. Réutiliser cette valeur pour changement de date, annulation et restauration, et détecter les collisions avant toute restauration.
- **REQ-008**: Les erreurs d'autorisation, chargement ou planification sont présentées explicitement; elles ne sont jamais converties en succès.
- **SEC-001**: Utiliser `SCHEDULE_EXACT_ALARM` et l'API de demande d'accès spécial; ne pas déclarer `USE_EXACT_ALARM`.
- **CON-001**: Ajouter dans le manifeste les permissions `POST_NOTIFICATIONS`, `SCHEDULE_EXACT_ALARM` et `RECEIVE_BOOT_COMPLETED` ainsi que les receivers exigés par `flutter_local_notifications` 22.3.1.
- **CON-002**: Une date choisie aujourd'hui après 09 h 00 est refusée avec une explication et sans supprimer la date précédemment sauvegardée.
- **CON-003**: Les dates restent synchronisées selon le dépôt maternité existant; la préférence d'activation ne va jamais dans Firestore.
- **CON-004**: Ne pas ajouter de rappels CPN, push ou de dépendance Flutter supplémentaire.
- **PAT-001**: Réutiliser `MaternityRepositoryFactory.maternity(uid: ...)`, les abstractions Riverpod existantes et `NotificationService` plutôt que dupliquer accès Firestore ou stockage invité.
- **PAT-002**: Maintenir la règle métier « enregistrer l'échéance d'abord, notifier séparément » et afficher distinctement une éventuelle erreur de planification locale.

## 2. Implementation Steps

### Implementation Phase 1

- GOAL-001: Configurer la livraison Android et rendre `NotificationService` apte à planifier précisément, refuser proprement et identifier chaque rappel de manière stable. Critère de sortie : tests unitaires du service verts et manifeste comprenant les composants Android requis.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-001 | Dans `android/app/src/main/AndroidManifest.xml`, ajouter `POST_NOTIFICATIONS`, `SCHEDULE_EXACT_ALARM` et `RECEIVE_BOOT_COMPLETED` sous `<manifest>`. Ajouter sous `<application>` les receivers `com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver` et `ScheduledNotificationBootReceiver`; déclarer sur le receiver de démarrage les actions `BOOT_COMPLETED`, `MY_PACKAGE_REPLACED` et `QUICKBOOT_POWERON` conformément au README installé de `flutter_local_notifications` 22.3.1. Ne pas ajouter `USE_EXACT_ALARM`. | ✅ | 2026-10-07 |
| TASK-002 | Dans `lib/core/services/notification_service.dart`, ajouter les abstractions injectables pour demander l'accès Android aux alarmes exactes et vérifier cet accès. Sur Android, avant `zonedSchedule`, vérifier `canScheduleExactNotifications`; si nécessaire, appeler `requestExactAlarmsPermission`, revérifier le résultat et lever une exception métier explicite si l'accès reste refusé. Conserver les demandes de permission d'affichage Android/iOS existantes et leurs erreurs explicites. | ✅ | 2026-10-07 |
| TASK-003 | Dans `lib/core/services/notification_service.dart`, calculer l'identifiant déterministe FNV-1a 32 bits sur les octets UTF-8 de `vaccineId`, appliquer `& 0x7fffffff` et remplacer zéro par `1`; transmettre cet identifiant à `scheduleVaccineReminder`, `cancelVaccineReminder` et `zonedSchedule`. Détecter les collisions au cours d'une restauration et renvoyer une erreur explicite au lieu de remplacer silencieusement un autre rappel. | ✅ | 2026-10-07 |
| TASK-004 | Dans `test/core/services/notification_service_test.dart`, ajouter des tests pour l'accès exact déjà autorisé, la demande puis l'octroi, le refus d'accès exact, le refus de permission d'affichage, l'identifiant stable, l'annulation par identifiant, et le rejet d'une date passée. Injecter les API natives derrière les fonctions de test déjà utilisées par `NotificationService`. | ✅ | 2026-10-07 |

### Implementation Phase 2

- GOAL-002: Rendre les taps et lancements à froid navigables vers le calendrier vaccinal, puis fixer l'heure de rappel à 09 h 00 locale. Critère de sortie : tests ciblés de navigation et du calcul de date verts, et l'ancienne date reste intacte si une planification échoue. TASK-001 à TASK-004 doivent être terminées avant cette phase.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-005 | Dans `lib/core/services/notification_service.dart`, remplacer le TODO de `_onNotificationTap` par un gestionnaire de tap injectable. Capturer également `getNotificationAppLaunchDetails()` pendant `initialize()` et exposer une méthode de consommation unique du payload de lancement afin d'éviter une navigation avant que le routeur soit monté. | ✅ | 2026-10-07 |
| TASK-006 | Dans `lib/main.dart` et `lib/config/routes/app_routes.dart`, raccorder le gestionnaire de tap à `appRouter.go(AppRoutes.vaccines)`. Traiter le payload de lancement après la première frame de `MediGuideApp`, et les taps ultérieurs via le callback actif. Conserver les routes existantes et ignorer les payloads inconnus sans navigation vers une route arbitraire. | ✅ | 2026-10-07 |
| TASK-007 | Dans `lib/features/maternity/presentation/controllers/maternity_provider.dart`, calculer la date locale à 09 h 00 avant la planification, transmettre l'identifiant stable du vaccin et préserver la séquence existante de sauvegarde de l'échéance puis planification. Si la date de 09 h 00 est passée, exposer une erreur claire; ne pas effacer la date déjà sauvegardée. | ✅ | 2026-10-07 |
| TASK-008 | Dans les tests du routeur et du service de notification, vérifier qu'un tap actif et un payload de lancement à froid dirigent vers `AppRoutes.vaccines`, que le payload n'est traité qu'une fois, et que le calcul date/heure conserve la date choisie à 09 h 00 dans le fuseau local. | ✅ | 2026-10-07 |

### Implementation Phase 3

- GOAL-003: Fournir le réglage global dans Profil et restaurer les échéances futures sans modifier les données métier. Critère de sortie : préférence locale persistée, annulation et restauration vérifiées en tests widget/unitaire, et toutes les erreurs visibles. TASK-001 à TASK-008 doivent être terminées avant cette phase.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-009 | Créer `VaccineReminderPreferences` dans `lib/core/services/vaccine_reminder_preferences.dart`, injecter l'instance `SharedPreferences` existante et définir la clé unique `vaccine_reminders_enabled`; l'absence de clé signifie `true`. Créer `VaccineReminderSettingsController` et son provider dans `lib/features/user_profile/presentation/controllers/vaccine_reminder_settings_controller.dart`, en réutilisant le provider partagé existant et sans persister la préférence dans Firestore. | ✅ | 2026-10-07 |
| TASK-010 | Implémenter l'activation dans le contrôleur : obtenir `MaternityRepositoryFactory.currentUid`, créer `MaternityRepositoryFactory.maternity(uid: uid)`, charger `getVaccinationSchedule()`, filtrer les vaccins non terminés avec une échéance strictement future, vérifier l'absence de collision des identifiants stables, demander les permissions requises et reprogrammer chaque rappel à 09 h 00 locale. N'enregistrer l'état actif qu'après restauration réussie; en cas d'échec, garder le réglage inactif et exposer l'erreur. | ✅ | 2026-10-07 |
| TASK-011 | Implémenter la désactivation dans le contrôleur : annuler les notifications locales, puis persister `false`. En cas d'échec d'annulation ou de persistance, ne pas afficher l'opération comme réussie et fournir une erreur explicite. Ne pas appeler `setVaccineReminder(..., null)` ni modifier les échéances enregistrées. | ✅ | 2026-10-07 |
| TASK-012 | Dans `lib/features/user_profile/presentation/pages/profile_page.dart`, ajouter une carte « Rappels de vaccination » avec `SwitchListTile`, indicateur de chargement et texte indiquant que le réglage est propre à l'appareil. Désactiver l'interaction pendant une opération et afficher les erreurs dans l'interface via un message accessible, sans cacher le statut des permissions Android. | ✅ | 2026-10-07 |
| TASK-013 | Injecter `VaccineReminderPreferences` et `NotificationService` dans `MaternityProvider` depuis le `Consumer` de la route vaccin dans `lib/config/routes/app_routes.dart`, qui lit les providers partagés. Dans `maternity_provider.dart` et `vaccine_schedule_page.dart`, si la préférence est inactive, enregistrer la date métier sans prétendre que la notification est planifiée et afficher « rappel enregistré, notifications désactivées ». Si elle est active, conserver le retour succès uniquement après planification réussie. | ✅ | 2026-10-07 |
| TASK-014 | Dans les tests Profil, contrôleur de préférences et calendrier vaccinal, vérifier la valeur initiale active, sa persistance après reconstruction, la désactivation avec annulation sans effacement des échéances, la restauration des seules échéances futures et non terminées, le mode invité et connecté via dépôts injectés, et l'absence de succès en cas d'erreur de chargement/permission/planification. | ✅ | 2026-10-07 |

### Implementation Phase 4

- GOAL-004: Valider le changement de bout en bout et documenter les limites de vérification native. Critère de sortie : tests ciblés, analyse statique et compilation Android debug réussis; le protocole de validation manuelle Android est renseigné dans le rapport d'exécution. TASK-001 à TASK-014 doivent être terminées avant cette phase.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-015 | Exécuter les tests ciblés du service, du contrôleur Profil, de la page Profil, du calendrier vaccinal et du routeur. Corriger seulement les régressions liées à ce changement et conserver les tests existants. | ✅ | 2026-10-07 |
| TASK-016 | Exécuter `flutter analyze lib`, puis `flutter build apk --debug`. Ne déclarer la validation réussie que si les deux commandes terminent sans erreur; distinguer les avertissements préexistants de ceux introduits par le changement. | ✅ | 2026-10-07 |
| TASK-017 | Effectuer sur un émulateur ou appareil Android un contrôle manuel : accorder/refuser `POST_NOTIFICATIONS`, accorder/refuser l'accès spécial `SCHEDULE_EXACT_ALARM`, planifier pour 09 h 00, toucher la notification app active/en arrière-plan/arrêtée, désactiver puis réactiver depuis Profil, et vérifier la restauration après redémarrage. |  |  |

## 3. Alternatives

- **ALT-001**: `USE_EXACT_ALARM` est écartée, car cette permission présente des contraintes d'éligibilité et de revue de distribution; `SCHEDULE_EXACT_ALARM` permet une demande explicite et révocable par l'utilisateur.
- **ALT-002**: Des rappels approximatifs sont écartés, car l'utilisateur a choisi de conserver l'heure précise demandée.
- **ALT-003**: Un simple `cancelAll` sans restauration depuis les échéances persistées est écarté, car il ne permettrait pas à l'utilisateur de réactiver les rappels de façon cohérente.

## 4. Dependencies

- **DEP-001**: `flutter_local_notifications` 22.3.1, déjà déclaré dans `pubspec.yaml`; aucune mise à niveau ou installation n'est prévue.
- **DEP-002**: `SharedPreferences`, déjà utilisé et fourni au scope de l'application pour les préférences locales.
- **DEP-003**: `go_router`, déjà utilisé par `appRouter`, `AppRoutes.vaccines` et `AppRoutes.profile`.
- **DEP-004**: `MaternityRepositoryFactory` et les dépôts Firestore/invité existants pour lire les échéances de vaccination.
- **DEP-005**: L'instance `SharedPreferences` fournie par `sharedPreferencesProvider` doit être injectée dans `VaccineReminderPreferences`, sans créer une seconde instance ni une seconde clé.

## 5. Files

- **FILE-001**: `android/app/src/main/AndroidManifest.xml` — autorisations et receivers de notifications Android.
- **FILE-002**: `lib/core/services/notification_service.dart` — permissions, programmation exacte, identifiants et callbacks de lancement/tap.
- **FILE-011**: `lib/core/services/vaccine_reminder_preferences.dart` — lecture/écriture de la préférence d'activation locale partagée.
- **FILE-003**: `lib/main.dart` — traitement différé du lancement depuis notification après montage du routeur.
- **FILE-004**: `lib/config/routes/app_routes.dart` — cible de navigation vaccinale existante; la route reste `/maternity/vaccines`.
- **FILE-005**: `lib/features/maternity/presentation/controllers/maternity_provider.dart` — heure locale, identifiant stable et état de programmation.
- **FILE-006**: `lib/features/maternity/presentation/pages/vaccine_schedule_page.dart` — retour utilisateur lorsque les notifications sont désactivées ou échouent.
- **FILE-007**: `lib/features/user_profile/presentation/controllers/vaccine_reminder_settings_controller.dart` — contrôleur/provider du réglage, annulation et restauration des rappels.
- **FILE-008**: `lib/features/user_profile/presentation/pages/profile_page.dart` — interrupteur de rappels et présentation des erreurs.
- **FILE-009**: `test/core/services/notification_service_test.dart` — tests permission, identifiant et planification.
- **FILE-010**: `test/features/user_profile/`, `test/features/maternity/` et tests routeur existants — tests de préférence, restauration et destination du tap.

## 6. Testing

- **TEST-001**: Vérifier avec `flutter test test/core/services/notification_service_test.dart` le refus de dates passées, les deux niveaux de permission Android, la gestion des erreurs, l'identifiant stable et l'annulation.
- **TEST-002**: Ajouter des tests unitaires du contrôleur de rappels pour valeur par défaut, persistance `SharedPreferences`, annulation, restauration depuis les dépôts vaccin, filtre des dates passées/terminées et erreurs visibles.
- **TEST-003**: Ajouter des tests widget de Profil pour le libellé du réglage, l'état initial, l'interaction en attente et l'affichage d'une erreur de permission/restauration.
- **TEST-004**: Ajouter un test de calendrier vaccinal vérifiant qu'une date est conservée à 09 h 00 locale et qu'une préférence inactive affiche explicitement que le rappel n'est pas notifié.
- **TEST-005**: Ajouter des tests de callback et de lancement à froid qui vérifient la navigation vers `/maternity/vaccines` après disponibilité du routeur et l'absence de double navigation.
- **TEST-006**: Exécuter les tests ciblés, `flutter analyze lib` et `flutter build apk --debug`.
- **TEST-007**: Tester sur Android réel/émulateur les autorisations, l'horaire, le tap dans les trois états de l'application, la désactivation/réactivation, et la restauration après redémarrage.

## 7. Risks & Assumptions

- **RISK-001**: Android peut révoquer ou refuser l'accès aux alarmes exactes; dans ce cas la date reste enregistrée, mais aucun rappel précis ne doit être annoncé comme actif.
- **RISK-002**: Les limites constructeur/batterie et les restrictions système peuvent retarder ou bloquer une alarme même lorsque la permission est accordée; seule une validation appareil permet d'observer le comportement réel.
- **RISK-003**: Une notification de lancement à froid peut arriver avant le montage de `MaterialApp.router`; le payload doit rester en attente et être consommé après la première frame.
- **RISK-004**: Des IDs numériques déterministes peuvent théoriquement entrer en collision; toute collision dans le lot restauré doit être détectée et signalée avant de remplacer un rappel.
- **ASSUMPTION-001**: L'interrupteur Profil contrôle les notifications de vaccination MediGuide sur cet appareil uniquement et n'affecte pas les autres applications.
- **ASSUMPTION-002**: Un vaccin est restauré uniquement si son état est incomplet et que son échéance sauvegardée est future.
- **ASSUMPTION-003**: Un tap ouvre le calendrier vaccinal sans tenter d'authentifier l'utilisateur ni de charger automatiquement une fiche vaccin précise.
- **ASSUMPTION-004**: La validation manuelle Android peut nécessiter un appareil ou émulateur où l'accès aux paramètres d'alarme exacte est disponible.

## 8. Related Specifications / Further Reading

- [Spécification approuvée des rappels de vaccination](../docs/superpowers/specs/2026-10-07-vaccine-reminders-profile-design.md)
- README installé de `flutter_local_notifications` 22.3.1 — section Android setup et gestion de `getNotificationAppLaunchDetails`.
- Documentation Android `SCHEDULE_EXACT_ALARM`: https://developer.android.com/about/versions/14/changes/schedule-exact-alarms
