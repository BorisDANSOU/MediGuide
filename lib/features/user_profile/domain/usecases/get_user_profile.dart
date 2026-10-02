import '../entities/user_profile_entity.dart';
import '../repositories/user_repository.dart';

/// Cas d'utilisation : lire le profil de l'utilisateur.
class GetUserProfile {
  GetUserProfile(this._repository);

  final UserRepository _repository;

  Future<UserProfileEntity> call() => _repository.getProfile();
}
