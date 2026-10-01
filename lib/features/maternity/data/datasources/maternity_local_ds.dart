class MaternityLocalDataSource {
  const MaternityLocalDataSource();

  Future<List<Map<String, dynamic>>> loadVaccines() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return const [
      {
        'id': 'bcg',
        'name': 'BCG',
        'recommendedMonth': 0,
        'status': false,
        'description': 'Vaccin indispensable à la naissance',
      },
    ];
  }
}
