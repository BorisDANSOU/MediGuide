import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/user_profile_entity.dart';

/// Lit et écrit le profil dans la mémoire du téléphone
class UserLocalDataSource {
  UserLocalDataSource(this._prefs);

  final SharedPreferences _prefs;

  // Clés de stockage
  static const String _countryKey = 'profile_country';
  static const String _cityKey = 'profile_city';

  /// Renvoie le profil enregistré, ou null si rien n'a encore été enregistré
  UserProfileEntity? readProfile() {
    final country = _prefs.getString(_countryKey);
    final city = _prefs.getString(_cityKey);

    // Premier lancement : rien n'est stocké
    if (country == null || city == null) return null;

    return UserProfileEntity(country: country, city: city);
  }

  /// Enregistre le pays et la ville
  Future<void> writeProfile(UserProfileEntity profile) async {
    await _prefs.setString(_countryKey, profile.country);
    await _prefs.setString(_cityKey, profile.city);
  }

  /// Enregistre [profile] seulement si l'utilisateur n'a pas encore choisi
  /// une zone de recherche sur cet appareil.
  Future<UserProfileEntity> writeProfileIfAbsent(
    UserProfileEntity profile,
  ) async {
    final savedProfile = readProfile();
    if (savedProfile != null) return savedProfile;

    await writeProfile(profile);
    return profile;
  }
}
