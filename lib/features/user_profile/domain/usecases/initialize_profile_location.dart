import '../../../../core/constants/supported_locations.dart';
import '../entities/user_profile_entity.dart';
import '../repositories/user_repository.dart';

/// Initialise la zone locale avec le pays du compte si aucune zone
/// n'a encore été enregistrée sur l'appareil.
class InitializeProfileLocation {
  InitializeProfileLocation(this._repository);

  final UserRepository _repository;

  Future<UserProfileEntity> call(String country) {
    final location = SupportedLocations.forCountry(country);
    return _repository.initializeProfileIfAbsent(
      UserProfileEntity(country: location.country, city: location.city),
    );
  }
}
