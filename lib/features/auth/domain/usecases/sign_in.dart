import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class SignIn {
  const SignIn(this.repository);

  final AuthRepository repository;

  Future<AppUser> call({required String email, required String password}) =>
      repository.signIn(email: email.trim().toLowerCase(), password: password);
}
