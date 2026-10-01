import 'package:flutter/material.dart';

class EmergencyFab extends StatelessWidget {
  const EmergencyFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {},
      tooltip: 'Urgence',
      child: const Icon(Icons.emergency),
    );
  }
}
