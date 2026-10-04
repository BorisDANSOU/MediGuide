# Conception — Dashboard Maternité MediGuide

Date : 2026-10-02

## Objectif

Remplacer le placeholder de l’onglet Maternité par un dashboard mobile inspiré de la maquette fournie. Cette première tranche porte sur le front et doit rester utilisable sans Firebase ni Firestore.

Le périmètre global du module reste celui du plan d’implémentation : suivi grossesse et bébé, CPN, vaccins et rappels, pharmacies de garde, cache Firestore/hors-ligne et suivi des tâches de santé et de sécurité. Le dashboard est la première étape visible de ce travail; les services distants, notifications effectives et fonctions pharmacies/hors-ligne seront intégrés dans des étapes ultérieures, sans être simulés dans cette page.

## Intégration

- Compléter `MaternityDashboardPage`, déjà présente dans `lib/features/maternity/presentation/pages/`.
- Faire pointer la route `AppRoutes.maternity` vers ce dashboard.
- Conserver la coquille existante, la barre de navigation et l’accès global Urgences sans modification.
- Garder `VaccineSchedulePage` séparée et hors du périmètre de cette première tranche.
- Construire les sections comme des widgets privés ou dédiés sous `presentation/widgets/`, en conservant les composants qui existent déjà.

## Structure et contenus exacts de la maquette

Le contenu défile verticalement. Reprendre les textes visibles ci-dessous; pour les lignes coupées par la capture, ne pas compléter les mots invisibles par supposition.

1. **En-tête et dossier**
	- Marque : « MediGuide · Maternité ».
	- Localisation : « Abidjan, Cocody ».
	- Bandeau : « Mode sécurisé · Carnet CPN & fiches d’urgences accessibles ».
	- Titre : « Espace Santé Maternelle ».
	- Dossier : « Dossier suivi : Awa K. (28 ans) · ID #MG-9821 ».
	- Conserver les boutons/icônes visibles de compte et de réglages.

2. **Sélecteur de parcours**
	- Onglet actif : « Ma Grossesse (En cours) ».
	- Autre onglet : « Mon Bébé (0–24 mois) ».

3. **Alerte obstétricale**
	- Sur-titre : « PROTOCOLE RÉACTIF OBSTÉTRICAL ».
	- Message : « Contractions rapprochées, saignements ou perte du liquide amniotique ? ».
	- Consigne : « N’attendez pas votre rendez-vous. Localisez la maternité de garde active dans votre zone. ».
	- Actions : « Urgences Maternité » et bouton d’appel avec icône téléphone.

4. **Suivi de grossesse et prochaine consultation**
	- Résumé : « 28e SA (7ème mois) » et badge « T3 • Trimestre Vital ».
	- Progression : « Début (Semaine 1) », « Terme estimé : 14 Nov. 2025 », « 40 SA ».
	- Rendez-vous : badge « Dans 4 jours »; titre « Consultation Prénatale (CPN 3) »; date « Jeudi 18 Septembre à 09h00 ».
	- Lieu visible : « Centre Médical Urbain (CMU) - Service… »; conserver la troncature si l’espace manque plutôt que d’inventer la suite.
	- Professionnel : « Dr. Konan • Sage-Femme d’État ».
	- Actions : « Confirmer présence » et « Itinéraire ».

5. **Échéances et examens recommandés**
	- Titre : « Échéances & Examens Recommandés »; action « Tout voir ».
	- Carte 1 : « 3ème Échographie obstétricale », statut « À planifier », texte « Recommandée entre 30 et 32 SA (Biométrie et position fœtale) », lien « 3 centres équipés à proximité » et action « Réserver → ».
	- Carte 2 : « Bilan biologique T2 & Glycémie », statut « Validé », texte « Effectué le 20 Août • Hémoglobine 11.8 g/dL (Normal) », actions « Consulter compte-rendu » et « PDF ».
	- Carte 3 : « Vaccination antitétanique (VAT) », statut « À venir », texte « Rappel immunitaire pour la mère et le nouveau-né », détail « Prévu lors de la CPN 3 (Dans 2 semaines max) » et chevron de détail.

6. **Repères et conseils validés**
	- Titre : « Repères & Conseils Validés ».
	- Sous-titre : « Élaborés par le collège national des sages-femmes ».
	- Ligne 1 : badge « Sécurité Vitale », durée « 2 min », titre « Signes d’alerte du 3e trimestre nécessitant un avis immédiat », action « Lire le mémo ».
	- Ligne 2 : badge « Préparation », durée « 3 min », titre « Trousse d’accouchement : les indispensables en maternité », action « Voir la liste ».
	- Ligne 3 : badge « Nutrition », durée « 4 min », titre visible « Alimentation et prévention de l’anémie : aliments locaux… », action « Consulter les recettes ».
	- Utiliser les trois photos correspondantes de la maquette dans le même ordre; ne pas les remplacer par des icônes ou des images de substitution.

7. **Ligne d’écoute**
	- Titre : « Ligne d’écoute Maternité ».
	- Texte : « Sages-femmes disponibles 24h/7j pour conseil non-urgent ».
	- Action : « Contacter ».

8. **Navigation basse**
	- Libellés visibles : « Accueil », « Carte », « Urgences », « Maternité », « Profil ».
	- La barre reste celle de la coquille existante; ne pas en créer une seconde dans le dashboard.

## Style et responsive

- Réutiliser `AppColors` et `AppTheme`; ne pas introduire une palette parallèle.
- Utiliser les couleurs sémantiques existantes : vert pour les actions santé, rouge pour les urgences, bleu clair pour les informations, fond clair et surfaces blanches.
- Respecter la typographie, les boutons, les rayons et les espacements du thème.
- Utiliser une mise en page scrollable, des libellés adaptatifs et des boutons de taille stable pour éviter débordements sur petits écrans.
- Afficher les photos en vignettes recadrées de façon cohérente avec la maquette, sans étirement.
- Les trois photos sont disponibles dans `assets/images/` : `maternity_warning.jpg`, `maternity_bag.jpg` et `maternity_nutrition.jpg`, utilisées respectivement pour l’alerte, la préparation et la nutrition.

## Données et interactions de démonstration

- Réutiliser `MaternityRepository`, `MaternityRepositoryImpl`, `MaternityLocalDataSource` et les entités existantes pour les listes CPN et vaccins; ne pas créer une deuxième source de données.
- Raccorder le contrôleur maternité existant au repository au lieu de conserver sa liste BCG séparée en dur. Les états de chargement et de liste vide restent gérés dans la présentation.
- Le profil de grossesse (semaine, trimestre, terme) et les détails de rendez-vous qui ne sont pas couverts par les modèles actuels restent des données de démonstration, identifiées comme telles; aucun repository distant ni Firebase n’est requis.
- Le sélecteur Grossesse/Bébé change localement la vue; le calendrier vaccinal et les CPN affichent les données provenant du repository local existant.
- Les actions de confirmation changent leur état localement; les actions sans fonctionnalité intégrée affichent un retour temporaire (par exemple un `SnackBar`) au lieu de simuler un appel réussi. Le service de rappel actuel étant un placeholder, aucune notification n’est annoncée comme programmée.
- Aucun numéro d’urgence, rendez-vous ou résultat médical réel ne doit être présenté comme provenant d’un compte utilisateur.

## Validation

- Un test widget vérifie que le dashboard affiche les sections principales.
- Un test widget vérifie que le sélecteur change de vue et que les trois photos attendues sont référencées dans les cartes de conseils.
- `flutter analyze` et `flutter test` doivent réussir après implémentation.
- Firebase et le lancement sur émulateur sont hors de cette validation de conception.