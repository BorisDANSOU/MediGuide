import '../entities/app_user.dart';

abstract class AuthRepository {
  /// Lève [AuthFailure] si l'e-mail ou le mot de passe est incorrect.
  Future<AppUser> signIn({required String email, required String password});

  /// Lève [AuthFailure] si l'e-mail est déjà utilisé.
  Future<AppUser> signUp({
    required String fullName,
    required String email,
    required String password,
    required String country,
    required String city,
  });
}
