import '../../domain/entities/vaccine_entity.dart';

class VaccineModel extends VaccineEntity {
  const VaccineModel({
    required super.id,
    required super.name,
    required super.recommendedMonth,
    required super.status,
    super.description,
    super.reminderAt,
  });

  factory VaccineModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    final recommendedMonth = json['recommendedMonth'];
    final status = json['status'] ?? json['completed'] ?? false;
    final description = json['description'];
    final reminder = json['reminderAt'];
    if (id is! String ||
        id.isEmpty ||
        name is! String ||
        recommendedMonth is! int ||
        recommendedMonth < 0 ||
        status is! bool ||
        (description != null && description is! String) ||
        (reminder != null && reminder is! DateTime)) {
      throw const FormatException('Invalid vaccine record.');
    }
    return VaccineModel(
      id: id,
      name: name,
      recommendedMonth: recommendedMonth,
      status: status,
      description: description as String?,
      reminderAt: reminder as DateTime?,
    );
  }
}
