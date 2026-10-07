import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/user_local_datasource.dart';
import '../../data/repositories/user_repo_impl.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/get_user_profile.dart';
import '../../domain/usecases/initialize_profile_location.dart';
import '../../domain/usecases/save_selected_country.dart';

// Branchement des dépendances

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider doit être fourni dans main.dart',
  );
});

final userLocalDataSourceProvider = Provider<UserLocalDataSource>((ref) {
  return UserLocalDataSource(ref.watch(sharedPreferencesProvider));
});

/// Type UserRepository (le contrat), valeur UserRepoImpl (l'implémentation)
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepoImpl(ref.watch(userLocalDataSourceProvider));
});

final getUserProfileProvider = Provider<GetUserProfile>((ref) {
  return GetUserProfile(ref.watch(userRepositoryProvider));
});

final saveSelectedCountryProvider = Provider<SaveSelectedCountry>((ref) {
  return SaveSelectedCountry(ref.watch(userRepositoryProvider));
});

final initializeProfileLocationProvider = Provider<InitializeProfileLocation>(
  (ref) => InitializeProfileLocation(ref.watch(userRepositoryProvider)),
);

// Le contrôleur : l'état du profil que les écrans vont observer

/// AsyncNotifier : gère un état qui se charge de façon asynchrone.
class UserProfileController extends AsyncNotifier<UserProfileEntity> {
  /// Appeler automatiquement à la première utilisation : charge le profil
  @override
  Future<UserProfileEntity> build() {
    return ref.read(getUserProfileProvider)();
  }

  /// Change de pays : enregistre puis met à jour l'état.
  /// Tous les écrans qui observent le provider seront notifiés.
  Future<void> selectCountry(String country) async {
    final updated = await ref.read(saveSelectedCountryProvider)(country);
    state = AsyncData(updated);
  }

  /// Utilise le pays du compte comme valeur initiale uniquement si l'appareil
  /// n'a pas déjà de zone de recherche enregistrée.
  Future<void> initializeLocationIfAbsent(String country) async {
    final profile = await ref.read(initializeProfileLocationProvider)(country);
    state = AsyncData(profile);
  }
}

///   ref.watch(userProfileControllerProvider)
final userProfileControllerProvider =
    AsyncNotifierProvider<UserProfileController, UserProfileEntity>(
      UserProfileController.new,
    );
