import 'package:flutter/material.dart';

class MaternityDashboardPage extends StatelessWidget {
  const MaternityDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Maternité')),
      body: const Center(child: Text('Dashboard maternité à compléter')),
    );
  }
}
