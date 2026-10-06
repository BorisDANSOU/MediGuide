class CpnEntity {
  const CpnEntity({
    required this.id,
    required this.name,
    required this.week,
    required this.completed,
    this.description,
  });

  final String id;
  final String name;
  final int week;
  final bool completed;
  final String? description;
}
