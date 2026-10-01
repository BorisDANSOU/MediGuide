class LocationService {
  const LocationService();

  Future<Map<String, double>> getCurrentLocation() async {
    // Placeholder for GPS integration.
    return const {'latitude': 6.1375, 'longitude': 1.2123};
  }
}
