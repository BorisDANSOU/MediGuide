import '../../../../core/constants/supported_locations.dart';
import '../entities/user_profile_entity.dart';
import '../repositories/user_repository.dart';

/// Cas d'utilisation : basculer l'application sur un autre pays.
/// La ville est déduite du pays choisi (une ville par pays dans le MVP).
class SaveSelectedCountry {
  SaveSelectedCountry(this._repository);

  final UserRepository _repository;

  /// Enregistre le nouveau pays et renvoie le profil mis à jour
  Future<UserProfileEntity> call(String country) async {
    final location = SupportedLocations.forCountry(country);
    final profile = UserProfileEntity(
      country: location.country,
      city: location.city,
    );
    await _repository.saveProfile(profile);
    return profile;
  }
}
