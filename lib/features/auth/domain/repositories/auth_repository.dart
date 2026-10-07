import '../entities/app_user.dart';

abstract class AuthRepository {
  /// Session en cours (persistée par Firebase Auth entre deux lancements),
  /// ou `null` si personne n'est connecté.
  AppUser? get currentUser;

  /// Lève [AuthFailure] si l'e-mail ou le mot de passe est incorrect.
  Future<AppUser> signIn({required String email, required String password});

  /// Crée le compte et enregistre le pays et la ville.
  /// Lève [AuthFailure] si l'e-mail est déjà utilisé.
  Future<AppUser> signUp({
    required String fullName,
    required String email,
    required String password,
    required String country,
    required String city,
  });

  /// Envoie l'e-mail de réinitialisation du mot de passe.
  Future<void> sendPasswordReset({required String email});

  Future<void> signOut();
}
