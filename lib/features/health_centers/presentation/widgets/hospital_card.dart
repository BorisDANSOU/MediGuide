import 'package:flutter/material.dart';

class HospitalCard extends StatelessWidget {
  const HospitalCard({super.key, required this.name, required this.type});

  final String name;
  final String type;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(name),
        subtitle: Text(type),
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}
