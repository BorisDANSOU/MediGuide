import '../entities/user_profile_entity.dart';

abstract class UserRepository {
  /// Renvoie le profil enregistré, ou le profil initial s'il n'y en a pas
  Future<UserProfileEntity> getProfile();

  /// Enregistre le profil
  Future<void> saveProfile(UserProfileEntity profile);

  /// Initialise le profil avec [profile] uniquement s'il n'existe pas encore.
  Future<UserProfileEntity> initializeProfileIfAbsent(
    UserProfileEntity profile,
  );
}
