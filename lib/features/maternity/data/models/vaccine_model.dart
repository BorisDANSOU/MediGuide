import '../../domain/entities/vaccine_entity.dart';

class VaccineModel extends VaccineEntity {
  const VaccineModel({
    required super.id,
    required super.name,
    required super.recommendedMonth,
    required super.status,
    super.description,
  });

  factory VaccineModel.fromJson(Map<String, dynamic> json) {
    return VaccineModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Vaccin',
      recommendedMonth: json['recommendedMonth'] ?? 0,
      status: json['status'] ?? false,
      description: json['description'],
    );
  }
}
