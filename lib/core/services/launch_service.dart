import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Service centralisé pour tout lancement d'URL externe :
/// - Appels téléphoniques  (scheme `tel:`)
/// - Itinéraires           (geo: sur Android, maps: sur iOS, fallback Google Maps)
///
/// API interne basée sur `launchUrl(Uri, {LaunchMode mode})` de url_launcher 6.3.3.
/// Source lue : lib/src/url_launcher_uri.dart + tests src/url_launcher_uri_test.dart.
///
/// ⚠️  `canLaunchUrl` est volontairement absent : il retourne toujours false sur
/// Android/iOS récents sans `<queries>` dans le Manifest, ce que confirment les docs.
/// On lance directement et on gère l'échec via le bool de retour.
class LaunchService {
  const LaunchService();

  // ---------------------------------------------------------------------------
  // Appel téléphonique
  // ---------------------------------------------------------------------------

  /// Lance un appel vers [number] (chiffres uniquement, ex: "185" ou "+22527202535").
  ///
  /// Construit `Uri(scheme: 'tel', path: number)` — forme préconisée par les tests
  /// du package (url_launcher_uri_test.dart, cas "non-web URL with default options").
  ///
  /// Mode : [LaunchMode.externalApplication] car `tel:` n'est pas http(s) et
  /// lancer en inAppWebView lève un [ArgumentError] (vérifié dans la source).
  ///
  /// Retourne `true` si le système a pu prendre en charge l'URI.
  Future<bool> callPhone(String number) async {
    // Nettoyer le numéro : garder chiffres, +, -, espaces (RFC 3966 §5)
    final cleaned = number.replaceAll(RegExp(r'[^\d+\-\s]'), '').trim();
    final uri = Uri(scheme: 'tel', path: cleaned);

    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  // ---------------------------------------------------------------------------
  // Itinéraire / navigation
  // ---------------------------------------------------------------------------

  /// Ouvre l'application de navigation native vers les coordonnées [lat]/[lng].
  ///
  /// Stratégie par plateforme :
  ///   - Android : `geo:lat,lng?q=lat,lng(label)` — scheme natif Android
  ///   - iOS/macOS : `https://maps.apple.com/?daddr=lat,lng` — deep-link Apple Maps
  ///   - Autres (web, desktop) : `https://www.google.com/maps/dir/?api=1&destination=lat,lng`
  ///
  /// [label] : texte affiché comme destination dans l'app de carte (optionnel).
  Future<bool> openDirections({
    required double lat,
    required double lng,
    String? label,
  }) async {
    final Uri uri;

    if (!kIsWeb && Platform.isAndroid) {
      // geo: scheme — Android ouvre Google Maps ou l'app de carte par défaut.
      // q=lat,lng(label) positionne un marqueur nommé.
      final query = label != null
          ? '$lat,$lng(${Uri.encodeComponent(label)})'
          : '$lat,$lng';
      uri = Uri(scheme: 'geo', path: '0,0', query: 'q=$query');
    } else if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
      // Apple Maps deep-link : daddr accepte lat,lng ou adresse textuelle.
      uri = Uri.https(
        'maps.apple.com',
        '/',
        <String, String>{
          'daddr': '$lat,$lng',
          ...?label != null ? <String, String>{'q': label} : null,
        },
      );
    } else {
      // Fallback universel : Google Maps directions via URL https (web, Linux, Windows).
      uri = Uri.https(
        'www.google.com',
        '/maps/dir/',
        <String, String>{
          'api': '1',
          'destination': '$lat,$lng',
          ...?label != null ? <String, String>{'destination_place_id': label} : null,
        },
      );
    }

    // externalApplication : on veut que l'OS délègue à l'app de carte, pas
    // ouvrir un WebView interne.
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
