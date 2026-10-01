class EmergencyNumberEntity {
  const EmergencyNumberEntity({
    required this.id,
    required this.name,
    required this.number,
    required this.country,
    this.icon,
  });

  final String id;
  final String name;
  final String number;
  final String country;
  final String? icon;
}
