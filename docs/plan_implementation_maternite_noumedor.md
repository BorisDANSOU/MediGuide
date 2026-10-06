# Plan d’implémentation — Module Maternité MediGuide

## 1. Contexte

Cette branche correspond au module maternité et aux fonctionnalités de soutien du projet MediGuide, selon les spécifications du dossier technique, du backlog partagé et de la maquette UI.

Responsabilités attendues :
- Espace maternité
- Suivi grossesse / bébé
- Consultations prénatales (CPN)
- Vaccins / rappel de vaccination
- Rappels locaux hors ligne
- Pharmacies de garde
- Cache Firestore / fonctionnement sans connexion
- Monitoring des tâches de santé et de sécurité des femmes enceintes

## 2. Objectif principal

Créer le module maternité fonctionnel, visible et robuste, en respectant la maquette visuelle et les exigences du projet :
- interface utilisateur claire et soignée
- données sanitaires structurées
- rappels hors ligne
- accès rapide aux informations de santé
- prise en charge des urgences et des rappels importants
- logique de données compatible avec le reste du projet MediGuide

## 3. Livrables attendus

### 3.1 Front-end — module maternité
- écran principal “Maternité” conforme à la maquette
- cartes de suivi grossesse
- bloc d’urgence maternité
- section consultation prénatale
- section examens / recommandations
- section conseils et repères
- ligne d’écoute / contact
- bottom navigation

### 3.2 Back-end / logique Flutter
- service Firestore pour le module maternité
- modèle de données pour grossesse, CPN et vaccins
- logique de notifications locales
- gestion du cache offline
- logique de filtrage des pharmacies de garde
- gestion des états chargement / erreur / vide

### 3.3 Fonctionnalités de support de la branche
- tableau de bord grossesse par semaines
- suivi du jeune enfant / bébé
- panneau des pharmacies de garde par pays / ville / date
- rappel des consultations prénatales et vaccins
- activation de la persistance Firestore en mode hors ligne

## 4. Structure du projet à créer

```text
lib/
  main.dart
  models/
    pregnancy_profile.dart
    prenatal_visit.dart
    vaccine.dart
    maternity_tip.dart
    pharmacy.dart
  services/
    maternity_service.dart
    pharmacy_service.dart
    notification_service.dart
  screens/
    maternity/
      maternity_screen.dart
  widgets/
    maternity/
      maternity_header.dart
      pregnancy_summary_card.dart
      emergency_alert_card.dart
      appointment_card.dart
      exam_card.dart
      advice_card.dart
      bottom_nav.dart
```

## 4. Structure du projet à créer

```text
lib/
  main.dart
  models/
    pregnancy_profile.dart
    prenatal_visit.dart
    vaccine.dart
    maternity_tip.dart
  services/
    maternity_service.dart
    notification_service.dart
  screens/
    maternity/
      maternity_screen.dart
  widgets/
    maternity/
      maternity_header.dart
      pregnancy_summary_card.dart
      emergency_alert_card.dart
      appointment_card.dart
      exam_card.dart
      advice_card.dart
      bottom_nav.dart
```

## 5. Plan de travail détaillé

### Jour 1 — Setup et base technique

Tâches :
- vérifier l’état du projet Flutter
- ajouter les dépendances nécessaires
- configurer Firebase
- activer Firestore offline persistence
- valider le build de base

Détails :
- `cloud_firestore`
- `firebase_core`
- `flutter_local_notifications`
- `timezone`
- `intl`

Résultat attendu :
- l’application démarre correctement
- Firestore est prêt
- les notifications locales peuvent être initialisées

### Jour 2 — Modèles de données maternité

Créer les modèles suivants :
- `PregnancyProfile`
- `PrenatalVisit`
- `VaccineReminder`
- `MaternityTip`
- `Pharmacy`

Champs à prévoir :
- `userId`
- `country`
- `city`
- `gestationalWeek`
- `trimester`
- `dueDate`
- `consultationDate`
- `location`
- `doctorName`
- `vaccineName`
- `reminderDate`
- `status`
- `pharmacyName`
- `isOnDuty`
- `dutyDate`

Résultat attendu :
- données structurées et prêtes à être affichées dans l’UI

### Jour 3 — Service Firestore + données de test

Créer `MaternityService` et `PharmacyService` avec les méthodes :
- `getPregnancyProfile()`
- `getPrenatalVisits()`
- `getVaccines()`
- `getTips()`
- `getOnDutyPharmacies(country, city, date)`

Implémentation :
- lecture depuis Firestore
- gestion des erreurs
- fallback sur données locales si nécessaire
- filtrage par pays / ville / date

Résultat attendu :
- le module affiche des données réelles ou simulées de manière fiable

### Jour 4 — Écran principal maternité

Créer `MaternityScreen` selon la maquette :
- header avec localisation
- “Mode sécurisé” / badge de sécurité
- bloc de résumé grossesse
- alertes maternité
- consultation prénatale
- section recommandations
- conseils / repères
- ligne d’écoute
- bottom navigation

Résultat attendu :
- l’écran ressemble à la maquette
- les sections sont clairement séparées
- le layout est lisible sur mobile

### Jour 5 — Widgets réutilisables

Créer des composants :
- `MaternityHeader`
- `PregnancySummaryCard`
- `EmergencyAlertCard`
- `AppointmentCard`
- `ExamCard`
- `AdviceCard`
- `BottomNavBar`

Résultat attendu :
- code propre et structuré
- plus facile à maintenir

### Jour 6 — Notifications locales et rappels

Créer `NotificationService` avec :
- `init()`
- `scheduleReminder()`
- `cancelReminder()`

Rappels à couvrir :
- consultation prénatale
- vaccination
- rendez-vous de suivi
- conseils urgents

Résultat attendu :
- notifications déclenchées localement sans internet
- rappels reliés aux données de grossesse

### Jour 7 — Pharmacies de garde + mode offline

Développer la logique de pharmacies :
- filtrage par pays/ville/date
- statut “de garde”
- affichage d’éléments utiles à la consultation
- validation du mode offline avec cache Firestore

Vérifier :
- fonctionnement sans connexion internet
- données persistantes dans le cache local
- réponse fluide même en mode avion

### Jour 8 — Tests, validation fonctionnelle et démonstration

Vérifier :
- chargement des données
- affichage d’un profil de grossesse
- affichage d’une consultation à venir
- affichage des vaccins
- affichage des pharmacies de garde
- notifications planifiées
- comportement sans connexion
- UI stable sur petit écran

Cas de test à couvrir :
- données vides
- données incomplètes
- utilisateur sans CPN planifiée
- vaccin déjà effectué
- rappel dans 1 jour
- pharmacie hors service / indisponible

Tâches finales :
- ajuster les couleurs, espacements, typographie
- harmoniser les widgets
- corriger les petits écarts visuels avec la maquette
- préparer les captures d’écran
- finaliser la démonstration du module

Résultat attendu :
- module prêt pour présentation
- UI cohérente et propre
- démonstration claire du parcours maternité

## 6. Critères de validation

Le module est validé si :
- l’écran maternité est conforme à la maquette
- les données sont affichées correctement
- les notifications se programment sans connexion
- les pharmacies de garde sont filtrées par date et ville
- les données sont bien chargées depuis Firestore ou cache local
- le design reste lisible et harmonieux
- le module est utilisable en condition réelle mobile

## 7. Points de vigilance

- ne pas partir sur une architecture trop complexe au début
- privilégier une base fonctionnelle avant la finition visuelle
- garder la logique médicale claire et lisible
- faire attention aux permissions notifications Android
- tester le comportement en mode hors ligne
- ne pas oublier le filtrage dynamique des pharmacies selon la localité

## 8. Prochaine action immédiate

Commencer par :
1. ajouter les dépendances Flutter
2. configurer Firestore offline
3. créer les modèles de données
4. préparer `MaternityScreen`
5. développer `NotificationService`
6. ensuite ajouter la logique des pharmacies de garde

## 9. Résumé rapide

Le module maternité doit permettre à une femme enceinte de suivre :
- son état de grossesse
- ses consultations prénatales
- ses vaccins
- ses rappels
- ses informations de sécurité
- ses conseils de santé
- les pharmacies de garde utiles à sa localisation

C’est la partie centrale du backend/features pour cette branche et le périmètre à travailler correspond bien au module Maternité + support de santé + offline + garde médicale.
