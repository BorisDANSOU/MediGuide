# Correction du débordement de l'en-tête Profil

## Problème

Sur une fenêtre très étroite, l'en-tête du profil force l'avatar et les informations du compte sur une ligne. Le texte de localisation manque alors de largeur et le `Row` déborde horizontalement.

## Comportement attendu

- L'en-tête reste horizontal lorsque sa largeur disponible le permet.
- Lorsque l'espace devient insuffisant, l'avatar et le contenu de compte sont présentés verticalement.
- Le nom et le courriel restent limités à une ligne avec ellipse.
- La ville et le pays peuvent revenir à la ligne et restent lisibles sans débordement.
- Aucun changement n'est apporté aux données, à l'authentification ou à la navigation.

## Implémentation

Adapter `ProfileHeaderCard` avec `LayoutBuilder` et un seuil de largeur dérivé de l'espace requis par l'avatar, l'espacement et le contenu. Dans le mode compact, placer le contenu sous l'avatar; présenter la localisation dans une configuration verticale/retournable qui ne dépend pas d'une largeur minimale supérieure à celle disponible.

## Tests

Ajouter un test widget qui affiche le Profil dans une fenêtre étroite avec une grande échelle de texte, vérifie l'absence d'exception de rendu après le premier et le dernier élément de la page, et confirme que le texte de localisation demeure dans l'arbre.

## Fichiers concernés

- `lib/features/user_profile/presentation/widgets/profile_header_card.dart`
- `test/features/user_profile/presentation/profile_page_test.dart`

## Éléments vérifiés

- L'exception fournie identifie le `Row` de localisation dans `profile_header_card.dart`.
- `ProfileHeaderCard` combine actuellement un avatar de 64 px, un espacement fixe et une colonne de texte dans un `Row`.
- Le projet fournit déjà `setScreen` et `expectNoOverflowWhileScrolling` dans `test/helpers.dart`.
