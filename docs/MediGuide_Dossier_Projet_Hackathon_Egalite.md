# MediGuide — Dossier de Cadrage Multi-Pays

*Spécifications Fonctionnelles, Architecture Technique & Guide d'Exécution (100% Dart / Flutter / Firebase)*

> **📌 CADRE DU PROJET & ARCHITECTURE 100% DART / FLUTTER / FIREBASE**  
> • Équipe : 4 Développeurs Flutter (5h/jour pendant 8 jours = 40h/dev = 160h hommes cumulées)  
> • Techno Unifiée : 100% Dart / Flutter Framework — Aucune dépendance externe en Python !  
> • Couverture Régionale : Togo (Lomé), Burkina Faso (Ouagadougou), Côte d'Ivoire (Abidjan)  
> • Service Data Dart : Extraction directe via requêtes HTTP Dart sur l'API Overpass API (OpenStreetMap) ou chargement d'Assets JSON locaux bundlés dans Flutter.  

## 1. Contextualisation & Vision Régionale

L'application MediGuide répond à un besoin critique d'accès aux soins de santé en Afrique de l'Ouest. Développée intégralement en **Dart et Flutter**, elle ne dépend d'aucun script tiers ou backend Python. Grâce à des services Dart dédiés et à des fichiers de configuration JSON, MediGuide prend en charge dès le premier jour 3 pays majeurs de la sous-région (Togo, Burkina Faso et Côte d'Ivoire).

## 2. Périmètre du Projet (Matrice Scope Multi-Pays 100% Dart)

| **Module**                  | **Inclus dans le MVP (À faire)**                                                                     | **Exclu du MVP**                                    | **Impact Multi-Pays & Stratégie Dart**                                                                                   |
|-----------------------------|------------------------------------------------------------------------------------------------------|-----------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------|
| Authentification & Localité | • Connexion/Inscription avec sélection du Pays & Ville<br>• Auto-connexion Firebase Auth             | • Authentification par empreinte / réseaux sociaux  | Le choix du Pays (Togo, Burkina Faso, CI) stocké dans le profil Firestore définit le filtre dynamique des requêtes Dart. |
| Seeding Data en Dart        | • Service HTTP Dart pour Overpass API (OSM)<br>• Helper Dart d'injection Firestore automatique batch | • Saisie manuelle rébarbative document par document | Un simple helper Dart exécuté au premier lancement ou en mode Debug popule les 150+ structures de santé.                 |
| Cartographie & Géoloc       | • Carte OpenStreetMap (flutter_map)<br>• Centrage dynamique selon le Pays/Ville                      | • Navigation GPS vocale tour-par-tour               | Composant Flutter natif purement Dart, très fluide et sans aucun frais d'API.                                            |
| Urgences & Numéros          | • Bouton FAB rouge Urgence<br>• Numéros d'urgence nationaux adaptés au pays (JSON)                   | • Suivi en temps réel des ambulances                | Commutation automatique des numéros gérée en Dart via un Asset JSON local (Togo: 118, Burkina Faso: 15, CI: 185).        |
| Espace Maternité (Bonus)    | • Carnet de santé numérique (Grossesse/Bébé)<br>• Rappels localisés (flutter_local_notifications)    | • Téléconsultation vidéo                            | Conforme au calendrier vaccinal régional CEDEAO. 100% fonctionnel hors-ligne sans serveur distant.                       |

## 3. Architecture des 8 Écrans & Parcours Utilisateur

### Écran 01 : Splash Screen (DANSOU (Front-end))

- **Rôle :** Ouverture & Vérification d'état

- **Détail :** Redirige automatiquement vers l'Accueil ou l'Écran Auth via StreamState Firebase.

### Écran 02 : Authentification (Inscription & Pays) (KABORE (Front-end))

- **Rôle :** Création de compte avec filtre localité

- **Détail :** Champs obligatoires : Email, Pass, Nom, Pays (Togo / Burkina Faso / Côte d'Ivoire) et Ville.

### Écran 03 : Accueil & Dashboard Principal (KABORE (Front-end))

- **Rôle :** Recherche & Raccourcis

- **Détail :** Barre de recherche filtrée automatiquement sur le Pays et la Ville de l'utilisateur.

### Écran 04 : Carte Interactive OpenStreetMap (DANSOU (Front-end))

- **Rôle :** Visualisation géographique

- **Détail :** Centrage dynamique sur Lomé, Ouagadougou ou Abidjan via flutter_map. Pins colorés.

### Écran 05 : Recherche & Liste des Résultats (KABORE (Front-end))

- **Rôle :** Filtrage avancé

- **Détail :** Requêtes Dart Firestore .where('country', '==', userCountry). Puces \[Ouvert 24h\], \[Garde\].

### Écran 06 : Fiche Structure Détaillée (KABORE (Front-end))

- **Rôle :** Informations pratiques & Actions

- **Détail :** Boutons d'appel natif (url_launcher) et d'itinéraire vers l'application GPS natif.

### Écran 07 : Espace Maternité (Bonus) (NOUMEDOR (Back-end))

- **Rôle :** Carnet Numérique & Rappels

- **Détail :** Suivi CPN et vaccins. Notifications locales fonctionnant sans internet.

### Écran 08 : Module Urgences & Profil (DJOBO (Back-end) / DANSOU)

- **Rôle :** Secours immédiats & Compte

- **Détail :** FAB Rouge central. Numéros d'urgence nationaux chargés depuis un JSON local.

## 4. Répartition des Rôles (Charge Équilibrée : 40h par Développeur)

| **Développeur**     | **Rôle Principal**          | **Missions Clés (100% Dart / Flutter)**                                                                                  | **Charge** |
|---------------------|-----------------------------|--------------------------------------------------------------------------------------------------------------------------|------------|
| KABORE (Front-end)  | Front-end & UI/UX           | Dashboard Accueil, Barre de recherche multi-critères, Filtres puces, Fiche détaillée des centres                         | 40h (5h/j) |
| DANSOU (Front-end)  | Front-end & Carte           | Splash Screen, BottomNavBar, Écran Profil & Changement Pays, Carte OpenStreetMap, Marqueurs Pins                         | 40h (5h/j) |
| DJOBO (Back-end)    | Back-end & Integration Data | Schéma Firestore, Service Dart Overpass HTTP (Togo/Burkina/CI), Data Seeding Dart/JSON, Urgences & Calls, Banner Offline | 40h (5h/j) |
| NOUMEDOR (Back-end) | Back-end & Features         | Espace Maternité, Carnet numérique (CPN & Vaccins), Notifications locales de rappel, Pharmacies de Garde, Cache Offline  | 40h (5h/j) |

## 5. ANNEXE TECHNIQUE — Code Dart / Flutter d'Extraction & Seeding Firestore

### 5.1 Service Dart : Requête HTTP vers Overpass API (OpenStreetMap)

Ce service écrit purement en **Dart** interroge directement l'API OpenStreetMap via le package HTTP de Flutter pour récupérer automatiquement la liste des centres de santé de Lomé, Ouagadougou et Abidjan :

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class OsmMedicalService {
// Coordonnées des zones (Bounding Boxes) pour Togo, Burkina Faso, Côte d'Ivoire
static const List<Map<String, String>> targetCities = [
{'country': 'Togo', 'city': 'Lomé', 'bbox': '6.1,1.1,6.3,1.3'},
{'country': 'Burkina Faso', 'city': 'Ouagadougou', 'bbox': '12.25,-1.65,12.45,-1.40'},
{'country': 'Côte d'Ivoire', 'city': 'Abidjan', 'bbox': '5.2,-4.1,5.5,-3.8'},
];

static Future<List<Map<String, dynamic>>> fetchCentersFromOSM() async {
List<Map<String, dynamic>> allCenters = [];

for (var loc in targetCities) {
final query = '''
[out:json][timeout:25];
(
nwr["amenity"="hospital"](${loc['bbox']});
nwr["amenity"="pharmacy"](${loc['bbox']});
nwr["amenity"="clinic"](${loc['bbox']});
);
out center;
''';

final response = await http.post(
Uri.parse('https://overpass-api.de/api/interpreter'),
body: query,
);

if (response.statusCode == 200) {
final data = json.decode(response.body);
for (var item in data['elements']) {
var tags = item['tags'] ?? {};
if (tags['name'] != null) {
allCenters.add({
'name': tags['name'],
'type': tags['amenity'] ?? 'clinic',
'city': loc['city'],
'country': loc['country'],
'latitude': item['lat'] ?? item['center']?['lat'],
'longitude': item['lon'] ?? item['center']?['lon'],
'phone': tags['phone'] ?? tags['contact:phone'], // null si absent : le bouton Appeler est masqué
'is24h': tags['opening_hours'] == '24/7' || tags['amenity'] == 'hospital',
});
}
}
}
}
return allCenters;
}
}
```

### 5.2 Helper Dart : Seeding Automatique de Firestore dans Flutter

Cette fonction Dart prend les données structurées et les injecte par paquets (batch) directement dans votre base Firestore Firebase depuis l'application Flutter :

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreSeeder {
static Future<void> seedDatabase(List<Map<String, dynamic>> centers) async {
final FirebaseFirestore firestore = FirebaseFirestore.instance;
final WriteBatch batch = firestore.batch();
final CollectionReference collection = firestore.collection('medical_centers');

for (var center in centers) {
DocumentReference docRef = collection.doc();
batch.set(docRef, center);
}

await batch.commit();
print("🚀 Seeding Firestore réussi depuis Flutter ! ${centers.length} centres ajoutés.");
}
}
```

### 5.3 Asset JSON Local pour les Numéros d'Urgence Multi-Pays (`assets/data/emergencies.json`)

Pour que les numéros d'urgence restent disponibles 100% hors-ligne sans dépendre du réseau, ils sont stockés dans un fichier JSON directement bundlé dans l'application Flutter :

```json
{
"Togo": [
{"name": "SAMU National", "number": "118", "type": "Medical"},
{"name": "Sapeurs-Pompiers", "number": "118", "type": "Fire"},
{"name": "Police Secours", "number": "117", "type": "Police"},
{"name": "CHU Sylvanus Olympio", "number": "+228 22 21 25 01", "type": "Hospital"}
],
"Burkina Faso": [
{"name": "SAMU Burkina Faso", "number": "15", "type": "Medical"},
{"name": "Sapeurs-Pompiers", "number": "18", "type": "Fire"},
{"name": "Police Secours", "number": "17", "type": "Police"},
{"name": "Gendarmerie", "number": "16", "type": "Police"},
{"name": "CHU Yalgado Ouédraogo", "number": "+226 25 31 16 55", "type": "Hospital"}
],
"Côte d'Ivoire": [
{"name": "SAMU Abidjan", "number": "185", "type": "Medical"},
{"name": "Groupement Sapeurs-Pompiers", "number": "180", "type": "Fire"},
{"name": "Police Secours", "number": "170", "type": "Police"},
{"name": "CHU de Cocody", "number": "+225 27 22 44 91 00", "type": "Hospital"}
]
}
```
