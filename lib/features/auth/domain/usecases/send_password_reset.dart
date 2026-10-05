import '../repositories/auth_repository.dart';

class SendPasswordReset {
  const SendPasswordReset(this.repository);

  final AuthRepository repository;

  Future<void> call({required String email}) =>
      repository.sendPasswordReset(email: email.trim().toLowerCase());
}
