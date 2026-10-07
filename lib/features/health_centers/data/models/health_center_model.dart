import '../../domain/entities/health_center_entity.dart';

class HealthCenterModel extends HealthCenterEntity {
  const HealthCenterModel({
    required super.id,
    required super.name,
    required super.type,
    required super.latitude,
    required super.longitude,
    super.city,
    super.country,
    super.phone,
    super.address,
    super.openingHours,
    super.is24h,
    super.isGuard,
  });

  factory HealthCenterModel.fromJson(Map<String, dynamic> json) {
    return HealthCenterModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Centre de santé',
      type: json['type'] ?? 'hospital',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      city: json['city'],
      country: json['country'],
      phone: json['phone'],
      address: json['address'],
      openingHours: json['openingHours'],
      is24h: json['is24h'] ?? false,
      isGuard: json['isGuard'] ?? false,
    );
  }
}
