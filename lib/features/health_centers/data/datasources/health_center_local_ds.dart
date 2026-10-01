class HealthCenterLocalDataSource {
  const HealthCenterLocalDataSource();

  Future<List<Map<String, dynamic>>> loadCachedCenters() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return const [];
  }
}
