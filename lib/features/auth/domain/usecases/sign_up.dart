import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class SignUp {
  const SignUp(this.repository);

  final AuthRepository repository;

  Future<AppUser> call({
    required String fullName,
    required String email,
    required String password,
    required String country,
    required String city,
  }) => repository.signUp(
    fullName: fullName.trim(),
    email: email.trim().toLowerCase(),
    password: password,
    country: country,
    city: city,
  );
}
