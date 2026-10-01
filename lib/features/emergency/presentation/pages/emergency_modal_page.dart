import 'package:flutter/material.dart';

class EmergencyModalPage extends StatelessWidget {
  const EmergencyModalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Numéros d’urgence')),
      body: const Center(child: Text('Modal d’urgence à compléter')),
    );
  }
}
