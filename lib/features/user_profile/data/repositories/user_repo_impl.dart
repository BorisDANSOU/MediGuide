import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_local_datasource.dart';

/// Implémente le contrat du domaine (UserRepository) avec le stockage local.
class UserRepoImpl implements UserRepository {
  UserRepoImpl(this._localDataSource);

  final UserLocalDataSource _localDataSource;

  @override
  Future<UserProfileEntity> getProfile() async {
    // S'il n'y a rien d'enregistré, on renvoie le profil par défaut (Togo)
    return _localDataSource.readProfile() ?? UserProfileEntity.initial;
  }

  @override
  Future<void> saveProfile(UserProfileEntity profile) {
    return _localDataSource.writeProfile(profile);
  }
}
