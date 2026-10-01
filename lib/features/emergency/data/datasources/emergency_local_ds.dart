class EmergencyLocalDataSource {
  const EmergencyLocalDataSource();

  Future<List<Map<String, dynamic>>> loadEmergencies() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return const [
      {'name': 'Urgence médicale', 'number': '112', 'country': 'Togo'},
      {'name': 'Police', 'number': '117', 'country': 'Togo'},
      {'name': 'Pompiers', 'number': '118', 'country': 'Togo'},
    ];
  }
}
