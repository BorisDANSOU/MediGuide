# Conception — Écran Urgences MediGuide

Date : 2026-10-02

## Objectif

Remplacer le placeholder Urgences par un écran mobile inspiré de la maquette fournie. Cette première tranche est un front de démonstration local; elle ne prétend ni contacter les secours ni fournir une liste vérifiée de services en temps réel.

## Intégration dans la navigation

- Faire d’Urgences une destination de la `StatefulShellRoute`, à l’index 2, entre Carte et Maternité.
- Garder la barre basse et le bouton central d’urgence visibles; toucher le bouton central sélectionne la branche Urgences au lieu de pousser une page modale indépendante.
- Décaler les index Maternité et Profil aux index 3 et 4 dans la barre basse.
- Faire pointer les accès d’urgence depuis les autres écrans vers la destination Urgences, sans empiler de doublons de navigation.

## Contenu de l’écran

Construire une page verticale scrollable, dans cet ordre :

1. En-tête « MediGuide · Urgences » et localisation « Abidjan, Cocody ».
2. Indicateur discret « Données de démonstration »; ne pas afficher comme promesses vérifiées les mentions d’appel gratuit, de fonctionnement sans crédit ou de disponibilité réelle.
3. Carte rouge « Numéros d’Urgence Vitale » avec le contexte « Côte d’Ivoire • Abidjan » et les numéros visibles sur la maquette : SAMU 185, Pompiers 180, Police Secours 170 / 111 et Anti-Poisons +225 27 20 25 35.
4. Repère de localisation de démonstration « Cocody, Carrefour Duncan », sans demander la position réelle.
5. Section « Services nationaux prioritaires » avec cartes SAMU, sapeurs-pompiers, police et anti-poisons.
6. Section « Urgences Hospitalières » avec les deux entrées de démonstration visibles dans la maquette : CHU de Cocody et Urgences Médico-Chirurgicales PISAM.
7. Section « Pharmacies de Garde Immédiates » avec Pharmacie Sainte-Cécile et Pharmacie des Étoiles, présentées comme exemples non vérifiés.
8. Conseil « Conseil d’appel d’urgence » reprenant l’instruction visible sur la maquette.

Les textes, nombres et lieux du visuel sont des exemples de maquette et doivent rester clairement marqués comme non vérifiés avant toute publication réelle.

## Données et actions

- Réutiliser les couches `EmergencyRepository` et `EmergencyProvider` pour les numéros chargés par pays; injecter le repository au lieu de conserver deux numéros codés en dur dans le provider.
- Garder les données actuelles du Togo distinctes des données d’exemple Côte d’Ivoire; ne jamais afficher 112/117/118 comme numéros d’Abidjan.
- Les hôpitaux et pharmacies restent des fixtures de démonstration locales dans cette première tranche; aucun Firebase, géolocalisation ou statut d’ouverture réel n’est introduit.
- Les boutons Appeler, Composer et Itinéraire donnent un retour explicite « démonstration, aucune action réelle effectuée »; ils ne lancent ni téléphone ni navigation.
- Gérer chargement, erreur et liste vide pour les numéros issus du repository.

## Style et tests

- Réutiliser `AppColors` et `AppTheme`, avec le rouge d’urgence existant et les surfaces claires de l’application.
- Préserver les dimensions mobiles, le défilement, les libellés et les cibles tactiles de la maquette.
- Tester l’affichage des sections et le caractère démonstratif des actions; tester le chargement des numéros depuis un repository fake.
- Valider par `flutter analyze` et `flutter test`.