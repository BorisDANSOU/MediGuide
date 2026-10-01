class HealthCenterRemoteDataSource {
  const HealthCenterRemoteDataSource();

  Future<List<Map<String, dynamic>>> fetchNearbyCenters({
    required double latitude,
    required double longitude,
    double radiusInKm = 10,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    return [
      {
        'id': 'h1',
        'name': 'Centre Hospitalier Régional',
        'type': 'hospital',
        'latitude': latitude,
        'longitude': longitude,
        'city': 'Lomé',
        'country': 'Togo',
        'phone': '+228 00000000',
      },
    ];
  }
}
