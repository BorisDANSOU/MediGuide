/// Utilisateur connecté.
class AppUser {
  const AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    this.country,
    this.city,
  });

  final String id;
  final String fullName;
  final String email;

  /// Pays et ville choisis à l'inscription (collection Firestore `users`).
  /// `null` si le profil Firestore n'a pas pu être lu (hors ligne).
  final String? country;
  final String? city;

  /// Prénom pour la salutation ; `null` si le nom est inconnu.
  String? get firstName {
    final first = fullName.trim().split(RegExp(r'\s+')).first;
    return first.isEmpty ? null : first;
  }
}

/// Erreur d'authentification avec un message prêt à afficher.
class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
