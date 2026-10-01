class UserLocalDataSource {
  const UserLocalDataSource();

  Future<Map<String, String>> loadProfile() async {
    return const {'country': 'Togo', 'city': 'Lomé'};
  }

  Future<void> saveProfile({
    required String country,
    required String city,
  }) async {
    await Future<void>.value();
  }
}
