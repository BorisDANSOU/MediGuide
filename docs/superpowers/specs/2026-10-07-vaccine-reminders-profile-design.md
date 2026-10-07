# Rappels de vaccination fiables et réglage dans Profil

## Objectif

Fiabiliser les rappels locaux de vaccination sur Android, ouvrir le calendrier vaccinal lorsqu'un utilisateur touche une notification et permettre d'activer ou désactiver ces rappels depuis Profil sans perdre les dates déjà enregistrées.

## Comportement

- Planifier les rappels à 09 h 00, heure locale, à la date choisie. Refuser clairement une date dont l'heure de rappel est déjà passée.
- Sur Android, demander l'autorisation d'afficher des notifications et l'accès spécial aux alarmes exactes avant toute planification précise. Déclarer `SCHEDULE_EXACT_ALARM`, `RECEIVE_BOOT_COMPLETED` et les receivers requis par `flutter_local_notifications` 22.3.1 dans `android/app/src/main/AndroidManifest.xml`. Ne pas utiliser `USE_EXACT_ALARM`, qui est soumis aux règles de distribution Google Play.
- Si une autorisation est refusée, ne pas présenter la notification comme programmée; préserver la date métier déjà enregistrée et exposer un message explicite avec l'action nécessaire.
- À l'ouverture d'une notification, naviguer vers `AppRoutes.vaccines`. Gérer le callback lorsque l'application tourne et les détails de lancement lorsque la notification démarre l'application.
- Ajouter dans Profil un interrupteur global « Rappels de vaccination », activé par défaut. Persister sa valeur dans `SharedPreferences`, sur l'appareil uniquement.
- Désactiver l'interrupteur annule les notifications locales de vaccination, sans supprimer les dates sauvegardées dans Firestore ou dans le stockage local invité. Tant que l'option est désactivée, une nouvelle date peut être sauvegardée mais l'interface doit indiquer que sa notification n'est pas active.
- Réactiver l'interrupteur recharge le calendrier de vaccination du compte courant ou du mode invité et reprogramme les rappels futurs sauvegardés pour les vaccins non terminés. Une erreur de chargement, d'autorisation ou de planification est présentée à l'utilisateur et ne doit pas être masquée par un état de succès.
- Utiliser un identifiant de notification stable par vaccin afin que replanification, annulation et restauration après désactivation restent cohérentes.

## Hors périmètre

- Ne pas ajouter de réglage de notification pour les consultations prénatales (CPN) ou les notifications push.
- Ne pas synchroniser la préférence d'activation dans Firestore.
- Ne pas modifier ni supprimer les dates de rappel déjà enregistrées pour les vaccins.
- Ne pas utiliser `USE_EXACT_ALARM`.

## Approches considérées

- **Préférence globale restaurable dans Profil (retenue)** : conserve un contrôle simple et réactive les dates métier déjà enregistrées lorsque l'utilisateur réactive les rappels.
- **Interrupteur global qui annule seulement** : écarte cette option, car la réactivation pourrait laisser des dates enregistrées sans notifications correspondantes.
- **Contrôle par vaccin uniquement dans le calendrier** : écarte cette option, car elle ne fournit pas le contrôle global demandé dans Profil.

## Fichiers à examiner ou modifier

- `android/app/src/main/AndroidManifest.xml`
- `lib/core/services/notification_service.dart`
- `lib/config/routes/app_routes.dart`
- `lib/main.dart`
- `lib/features/maternity/presentation/controllers/maternity_provider.dart`
- `lib/features/maternity/presentation/pages/vaccine_schedule_page.dart`
- `lib/features/user_profile/presentation/pages/profile_page.dart`
- `lib/features/user_profile/presentation/controllers/user_profile_controller.dart` ou un contrôleur dédié aux préférences de rappel
- `test/core/services/notification_service_test.dart`
- Tests de Profil, de calendrier vaccinal et de routage concernés

## Validation

- Tests unitaires : refus de permission de notification, refus d'alarme exacte, date passée, horaire local à 09 h 00, identifiants stables, activation/désactivation, annulation et restauration des rappels futurs.
- Tests widget/intégration : la préférence apparaît et persiste dans Profil; les dates métier survivent à la désactivation; une erreur de restauration n'affiche pas un succès; un tap de notification cible `/maternity/vaccines`, y compris au lancement à froid.
- Exécuter les tests ciblés, `flutter analyze lib` et une compilation Android debug.
- Valider manuellement sur Android l'autorisation de notifications, l'accès spécial aux alarmes exactes, le redémarrage de l'appareil et l'ouverture de l'application via notification. Les tests Flutter seuls ne prouvent pas la livraison native.

## Éléments vérifiés

- `flutter_local_notifications` est en version 22.3.1 et son README exige les permissions, receivers et le traitement de `getNotificationAppLaunchDetails` correspondants.
- Le code planifie actuellement avec `exactAllowWhileIdle`, demande seulement la permission d'affichage et utilise le nom du vaccin comme payload; son callback de tap contient un TODO.
- Les dates de rappel sont déjà conservées dans l'entité vaccin et dans les dépôts Firestore / invité.
- Le routeur expose `AppRoutes.vaccines`, et Profil n'a pas encore de préférence de rappel.
