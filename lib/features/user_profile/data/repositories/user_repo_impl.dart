import '../../domain/entities/user_profile_entity.dart';
import '../datasources/user_local_ds.dart';

class UserRepositoryImpl {
  const UserRepositoryImpl(this.localDataSource);

  final UserLocalDataSource localDataSource;

  Future<UserProfileEntity> getProfile() async {
    final data = await localDataSource.loadProfile();
    return UserProfileEntity(
      country: data['country'] ?? 'Togo',
      city: data['city'] ?? 'Lomé',
    );
  }

  Future<void> updateCountry({
    required String country,
    required String city,
  }) async {
    await localDataSource.saveProfile(country: country, city: city);
  }
}
