import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Ouvre le composeur avec le numéro prérempli (l'utilisateur valide l'appel).
Future<void> callPhoneNumber(BuildContext context, String phone) async {
  final uri = Uri(scheme: 'tel', path: phone.replaceAll(' ', ''));
  final ok = await launchUrl(uri);
  if (!ok && context.mounted) {
    _snack(context, 'Impossible d’ouvrir le téléphone. Composez le $phone.');
  }
}

/// Ouvre l'application de cartes avec l'itinéraire vers le point donné.
Future<void> openDirections(
  BuildContext context, {
  required double latitude,
  required double longitude,
  required String label,
}) async {
  final uri = Uri.https('www.google.com', '/maps/dir/', {
    'api': '1',
    'destination': '$latitude,$longitude',
  });
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok && context.mounted) {
    _snack(context, 'Impossible d’ouvrir l’itinéraire vers $label.');
  }
}

void _snack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
