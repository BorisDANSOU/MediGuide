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
    );
  }
}
