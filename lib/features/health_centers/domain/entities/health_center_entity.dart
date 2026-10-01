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
  });

  final String id;
  final String name;
  final String type;
  final double latitude;
  final double longitude;
  final String? city;
  final String? country;
  final String? phone;
}
