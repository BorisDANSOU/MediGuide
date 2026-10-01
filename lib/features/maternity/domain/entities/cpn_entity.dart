class CpnEntity {
  const CpnEntity({
    required this.id,
    required this.name,
    required this.month,
    required this.completed,
  });

  final String id;
  final String name;
  final int month;
  final bool completed;
}
