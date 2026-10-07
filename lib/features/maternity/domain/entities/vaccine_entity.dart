class VaccineEntity {
  const VaccineEntity({
    required this.id,
    required this.name,
    required this.recommendedMonth,
    required this.status,
    this.description,
    this.reminderAt,
  });

  final String id;
  final String name;
  final int recommendedMonth;
  final bool status;
  final String? description;
  final DateTime? reminderAt;
}
