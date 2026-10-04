import 'package:flutter/material.dart';

/// Une colonne de cartes sur téléphone, deux à partir de [twoColumnsFrom] px.
class ResponsiveCards extends StatelessWidget {
  const ResponsiveCards({
    super.key,
    required this.children,
    this.twoColumnsFrom = 640,
    this.spacing = 12,
  });

  final List<Widget> children;
  final double twoColumnsFrom;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= twoColumnsFrom ? 2 : 1;
        final width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final c in children) SizedBox(width: width, child: c),
          ],
        );
      },
    );
  }
}

/// Contenu centré et limité en largeur (tablette, paysage).
class MaxWidth extends StatelessWidget {
  const MaxWidth({super.key, required this.child, this.maxWidth = 960});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    ),
  );
}
