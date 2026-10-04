# Dossier Technique & Guide d'Implémentation — Module NOUMEDOR
**Projet :** MediGuide (Hackathon Santé Afrique de l'Ouest : Togo, Burkina Faso, Côte d'Ivoire)  
**Développeur :** NOUMEDOR (Back-end & Features — 40h de charge)  
**Stack :** 100% Dart / Flutter / Firebase (Cloud Firestore & Local Notifications)

---

## 1. Vue d'Ensemble du Périmètre (NOUMEDOR)
En tant que responsable Back-end & Features, ta mission consiste à garantir la forte valeur sociale de l'application à travers le suivi sanitaire sensible (maternité, vaccins, pharmacies de garde) et à assurer sa robustesse technique en milieu à faible connectivité grâce au cache hors-ligne.

| Fonctionnalité | Rôle & Objectif | Technologie / Paquet | Impact Multi-Pays / Local |
| :--- | :--- | :--- | :--- |
| **Espace Maternité** | Tableau de bord grossesse (par semaines) et suivi du jeune enfant | Cloud Firestore | Conforme aux standards sanitaires régionaux |
| **Carnet Numérique** | Suivi des Consultations Prénatales (CPN) & Calendrier vaccinal| Cloud Firestore | Stockage structuré par profil utilisateur |
| **Rappels Hors-Ligne** | Notifications locales programmées pour les visites et vaccins | `flutter_local_notifications` | Fonctionne 100% sans connexion internet |
| **Pharmacies de Garde** | Liste mise à jour des pharmacies de garde filtrée par date et ville | Cloud Firestore (`.where()`) | Filtrage dynamique par pays/ville |
| **Mode Offline & Cache** | Résilience de l'application en zone blanche / mode avion | Firestore Offline Settings | Persistance locale activée |

---

## 2. Implémentation Technique — Code Dart / Flutter

### 2.1 Configuration du Mode Offline Firestore
Pour garantir que l'application reste fonctionnelle même sans connexion Internet (mode avion ou coupure réseau fréquente en Afrique de l'Ouest), active la persistance du cache local dans ton `main.dart` :

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Activation de la persistance offline Firestore
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  runApp(const MediGuideApp());
}

class MediGuideApp extends StatelessWidget {
  const MediGuideApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediGuide Noumedor Module',
      home: Scaffold(
        appBar: AppBar(title: const Text('MediGuide - Espace Maternité & Garde')),
        body: const Center(child: Text('Module Noumedor Initialisé avec Succès')),
      ),
    );
  }
}
```

---

### 2.2 Service de Notifications Locales Hors-Ligne (`maternity_notifications.dart`)
Ce service gère la programmation de rappels locaux pour les Consultations Prénatales (CPN) et les vaccins de l'enfant sans dépendre d'un serveur distant :

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class MaternityNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> scheduleVaccineReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidDetails(
          'maternity_channel_id',
          'Rappels Maternité & Vaccins',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
```

---

### 2.3 Requête Firestore : Pharmacies de Garde par Ville & Date (`pharmacy_service.dart`)
Récupération dynamique des pharmacies de garde en fonction de la localité de l'utilisateur (Togo, Burkina Faso, Côte d'Ivoire) et de la date du jour :

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class PharmacyService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Stream<QuerySnapshot> getOnDutyPharmacies({
    required String country,
    required String city,
    required String currentDate, // Format 'YYYY-MM-DD'
  }) {
    return _firestore
        .collection('pharmacies')
        .where('country', isEqualTo: country)
        .where('city', isEqualTo: city)
        .where('duty_date', isEqualTo: currentDate)
        .where('isOnDuty', isEqualTo: true)
        .snapshots();
  }
}
```

---

## 3. Plan d'Action sur 8 Jours (Charge : 5h / jour)

- **Jour 1 :** Configuration de l'environnement, des dépendances (`cloud_firestore`, `flutter_local_notifications`) et activation du cache offline Firestore.
- **Jour 2 :** Modélisation des données Firestore pour l'Espace Maternité et le carnet numérique (CPN & Vaccins CEDEAO).
- **Jour 3 :** Développement des écrans UI du tableau de bord de grossesse et liaison avec les collections Firestore.
- **Jour 4 :** Implémentation du service de notifications locales et tests de programmation des rappels hors-ligne.
- **Jour 5 :** Développement de la logique de filtrage des Pharmacies de Garde par pays, ville et date.
- **Jour 6 :** Intégration croisée avec l'équipe (synchronisation avec les profils utilisateurs créés par KABORE et la carte de DANSOU).
- **Jour 7 :** Tests de résilience en mode avion (vérification du cache Firestore et du déclenchement des notifications).
- **Jour 8 :** Corrections de bugs, optimisation des performances UI et préparation de la démo du pitch.