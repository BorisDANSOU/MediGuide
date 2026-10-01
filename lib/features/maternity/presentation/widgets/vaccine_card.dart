import 'package:flutter/material.dart';

class VaccineCard extends StatelessWidget {
  const VaccineCard({
    super.key,
    required this.name,
    required this.month,
    required this.completed,
  });

  final String name;
  final int month;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          completed ? Icons.check_circle : Icons.pending,
          color: completed ? Colors.green : Colors.orange,
        ),
        title: Text(name),
        subtitle: Text('Mois recommandé : $month'),
      ),
    );
  }
}
