/// Modèle d'un centre de santé — collection Firestore `medical_centers`.
///
/// L'ID du document = ID OSM (ex: "node_123456"), ce qui rend le seeding
/// rejouable sans doublons.
class MedicalCenter {
  final String id; // "node_123", "way_456", "relation_789"
  final String name;
  final String nameLower; // normalisé (sans accents) pour la recherche
  final String type; // 'hospital' | 'clinic' | 'pharmacy'
  final String countryCode; // 'TG' | 'BF' | 'CI'
  final String country; // nom d'affichage
  final String city;
  final double latitude;
  final double longitude;
  final String? phone; // null => bouton "Appeler" masqué
  final String? address;
  final String? openingHours; // valeur OSM brute
  final bool is24h;

  /// Pharmacie de garde : NON alimenté par le seeding OSM (donnée absente).
  /// Géré à la main / par la feature de NOUMEDOR. Absent du document = false.
  final bool isGuard;

  const MedicalCenter({
    required this.id,
    required this.name,
    required this.nameLower,
    required this.type,
    required this.countryCode,
    required this.country,
    required this.city,
    required this.latitude,
    required this.longitude,
    this.phone,
    this.address,
    this.openingHours,
    this.is24h = false,
    this.isGuard = false,
  });

  /// Map écrite par le seeder. `isGuard` est volontairement exclu pour qu'un
  /// re-seeding (merge) n'écrase pas les valeurs saisies manuellement.
  Map<String, dynamic> toSeedMap() => {
        'name': name,
        'nameLower': nameLower,
        'type': type,
        'countryCode': countryCode,
        'country': country,
        'city': city,
        'latitude': latitude,
        'longitude': longitude,
        'phone': phone,
        'address': address,
        'openingHours': openingHours,
        'is24h': is24h,
        'source': 'osm',
      };

  factory MedicalCenter.fromMap(String id, Map<String, dynamic> data) {
    return MedicalCenter(
      id: id,
      name: data['name'] as String? ?? '',
      nameLower: data['nameLower'] as String? ?? '',
      type: data['type'] as String? ?? 'clinic',
      countryCode: data['countryCode'] as String? ?? '',
      country: data['country'] as String? ?? '',
      city: data['city'] as String? ?? '',
      latitude: (data['latitude'] as num).toDouble(),
      longitude: (data['longitude'] as num).toDouble(),
      phone: data['phone'] as String?,
      address: data['address'] as String?,
      openingHours: data['openingHours'] as String?,
      is24h: data['is24h'] as bool? ?? false,
      isGuard: data['isGuard'] as bool? ?? false,
    );
  }
}

const _accentsFrom = 'àâäáãåçéèêëíìîïñóòôöõúùûüýÿ';
const _accentsTo = 'aaaaaaceeeeiiiinooooouuuuyy';

/// Minuscules + suppression des accents. À utiliser aussi côté recherche
/// (sur le texte saisi) pour comparer avec `nameLower`.
String normalizeForSearch(String input) {
  final s = input.toLowerCase().replaceAll('œ', 'oe').replaceAll('æ', 'ae');
  final buf = StringBuffer();
  for (final ch in s.split('')) {
    final i = _accentsFrom.indexOf(ch);
    buf.write(i >= 0 ? _accentsTo[i] : ch);
  }
  return buf.toString().trim();
}