/// Le profil de l'utilisateur : pays et ville actifs.
/// Objet métier pur
class UserProfileEntity {
  const UserProfileEntity({required this.country, required this.city});

  final String country;
  final String city;

  /// Profil utilisé au premier lancement
  static const UserProfileEntity initial = UserProfileEntity(
    country: 'Togo',
    city: 'Lomé',
  );

  /// Copie du profil avec certains champs modifiés
  UserProfileEntity copyWith({String? country, String? city}) {
    return UserProfileEntity(
      country: country ?? this.country,
      city: city ?? this.city,
    );
  }

  // Deux profils avec le même pays et la même ville sont égaux.

  @override
  bool operator ==(Object other) =>
      other is UserProfileEntity &&
      other.country == country &&
      other.city == city;

  @override
  int get hashCode => Object.hash(country, city);
}
