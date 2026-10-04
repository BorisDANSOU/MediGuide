/// Utilisateur connecté. Le pays et la ville filtrent toutes les données.
class AppUser {
  const AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.country,
    required this.city,
  });

  final String id;
  final String fullName;
  final String email;
  final String country;
  final String city;

  String get firstName => fullName.trim().split(RegExp(r'\s+')).first;
}

/// Erreur d'authentification avec un message prêt à afficher.
class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
