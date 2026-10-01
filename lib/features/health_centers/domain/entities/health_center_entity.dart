class HealthCenterEntity {
  const HealthCenterEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    this.city,
    this.country,
    this.phone,
    this.address,
    this.openingHours,
    this.is24h = false,
    this.isGuard = false,
  });

  final String id;
  final String name;

  /// `hospital`, `clinic` ou `pharmacy` (voir SCHEMA.md).
  final String type;
  final double latitude;
  final double longitude;
  final String? city;
  final String? country;

  /// `null` : le bouton « Appeler » doit être masqué.
  final String? phone;
  final String? address;

  /// Valeur OSM brute, par exemple `Mo-Fr 07:30-18:00`.
  final String? openingHours;
  final bool is24h;

  /// Pharmacie de garde.
  final bool isGuard;
}
