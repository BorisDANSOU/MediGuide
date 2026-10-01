import 'package:flutter/material.dart';

class HealthCenterDetailPage extends StatelessWidget {
  const HealthCenterDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détails du centre')),
      body: const Center(child: Text('Détails du centre à compléter')),
    );
  }
}
