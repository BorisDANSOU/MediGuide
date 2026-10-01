import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/medical_center.dart';

class TargetCity {
  final String countryCode;
  final String country;
  final String city;

  /// Format Overpass : sud,ouest,nord,est
  final String bbox;

  const TargetCity(this.countryCode, this.country, this.city, this.bbox);
}

class OsmMedicalService {
  // Serveurs Overpass : si l'un est surchargé (504), on essaie le suivant.
  static const _endpoints = [
    'https://overpass-api.de/api/interpreter',
    'https://overpass.kumi.systems/api/interpreter',
  ];

  // Overpass demande d'identifier l'application qui appelle.
  static const _headers = {'User-Agent': 'MediGuide/1.0 (hackathon)'};

  /// Hypothèse MVP : un hôpital sans `opening_hours` est considéré ouvert 24h.
  /// Mettre à false pour ne se fier qu'à la donnée OSM.
  static const assumeHospitalsOpen24h = true;

  static const targetCities = <TargetCity>[
    TargetCity('TG', 'Togo', 'Lomé', '6.1,1.1,6.3,1.3'),
    TargetCity('BF', 'Burkina Faso', 'Ouagadougou', '12.25,-1.65,12.45,-1.40'),
    TargetCity('CI', "Côte d'Ivoire", 'Abidjan', '5.2,-4.1,5.5,-3.8'),
  ];

  /// Récupère toutes les villes. Une ville en échec n'empêche pas les autres.
  static Future<List<MedicalCenter>> fetchAll({
    void Function(String message)? onLog,
  }) async {
    final byId = <String, MedicalCenter>{};

    for (final city in targetCities) {
      try {
        final centers = await fetchCity(city);
        for (final c in centers) {
          byId[c.id] = c; // dédoublonnage par ID OSM
        }
        onLog?.call('${city.city} : ${centers.length} centres');
      } catch (e) {
        onLog?.call('${city.city} : ÉCHEC ($e)');
      }
      // Politesse envers l'instance publique d'Overpass.
      await Future.delayed(const Duration(seconds: 2));
    }
    return byId.values.toList();
  }

  static Future<List<MedicalCenter>> fetchCity(
    TargetCity city, {
    int maxRetries = 5,
  }) async {
    final query = '''
[out:json][timeout:60];
(
  nwr["amenity"="hospital"](${city.bbox});
  nwr["amenity"="clinic"](${city.bbox});
  nwr["amenity"="pharmacy"](${city.bbox});
);
out center tags;
''';

    for (var attempt = 1; attempt <= maxRetries; attempt++) {
      final endpoint = _endpoints[(attempt - 1) % _endpoints.length];
      final http.Response response;
      try {
        response = await http
            .post(
              Uri.parse(endpoint),
              headers: _headers,
              body: {'data': query}, // form-encoded, format attendu par Overpass
            )
            .timeout(const Duration(seconds: 90));
      } on TimeoutException {
        if (attempt == maxRetries) rethrow;
        await Future.delayed(Duration(seconds: 3 * attempt));
        continue;
      }

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return _parse(data['elements'] as List, city);
      }

      // 429 = trop de requêtes, 504 = serveur surchargé : on retente.
      if ((response.statusCode == 429 || response.statusCode == 504) &&
          attempt < maxRetries) {
        await Future.delayed(Duration(seconds: 5 * attempt));
        continue;
      }
      throw Exception('Overpass HTTP ${response.statusCode}');
    }
    throw Exception('Overpass : tentatives épuisées');
  }

  static List<MedicalCenter> _parse(List elements, TargetCity city) {
    final result = <MedicalCenter>[];

    for (final item in elements) {
      final tags = (item['tags'] as Map?)?.cast<String, dynamic>() ?? {};

      final name = (tags['name'] as String?)?.trim();
      if (name == null || name.isEmpty) continue;

      final lat = (item['lat'] ?? item['center']?['lat']) as num?;
      final lon = (item['lon'] ?? item['center']?['lon']) as num?;
      if (lat == null || lon == null) continue;

      final type = tags['amenity'] as String? ?? 'clinic';
      final openingHours = tags['opening_hours'] as String?;

      final is24h = openingHours == '24/7' ||
          (assumeHospitalsOpen24h &&
              type == 'hospital' &&
              openingHours == null);

      final address = [
        tags['addr:housenumber'],
        tags['addr:street'],
        tags['addr:suburb'],
      ].whereType<String>().join(' ').trim();

      result.add(MedicalCenter(
        id: '${item['type']}_${item['id']}',
        name: name,
        nameLower: normalizeForSearch(name),
        type: type,
        countryCode: city.countryCode,
        country: city.country,
        city: city.city,
        latitude: lat.toDouble(),
        longitude: lon.toDouble(),
        phone: (tags['phone'] ?? tags['contact:phone']) as String?,
        address: address.isEmpty ? null : address,
        openingHours: openingHours,
        is24h: is24h,
      ));
    }
    return result;
  }
}