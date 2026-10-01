import 'package:flutter/material.dart';

class VaccineSchedulePage extends StatelessWidget {
  const VaccineSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendrier vaccinal')),
      body: const Center(child: Text('Calendrier vaccinal à compléter')),
    );
  }
}
