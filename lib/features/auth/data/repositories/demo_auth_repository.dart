import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Authentification en mémoire, en attendant Firebase Auth.
/// Les comptes créés disparaissent au redémarrage de l'application.
class DemoAuthRepository implements AuthRepository {
  DemoAuthRepository();

  static const demoEmail = 'demo@mediguide.app';
  static const demoPassword = 'mediguide';

  final Map<String, ({AppUser user, String password})> _accounts = {
    demoEmail: (
      user: const AppUser(
        id: 'demo',
        fullName: 'Utilisateur Démo',
        email: demoEmail,
        country: 'Burkina Faso',
        city: 'Ouagadougou',
      ),
      password: demoPassword,
    ),
  };

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final account = _accounts[email];
    if (account == null) {
      throw const AuthFailure(
        'Aucun compte avec cet e-mail. Créez un compte en 1 minute.',
      );
    }
    if (account.password != password) {
      throw const AuthFailure('Mot de passe incorrect.');
    }
    return account.user;
  }

  @override
  Future<AppUser> signUp({
    required String fullName,
    required String email,
    required String password,
    required String country,
    required String city,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (_accounts.containsKey(email)) {
      throw const AuthFailure('Un compte existe déjà avec cet e-mail.');
    }
    final user = AppUser(
      id: 'local-${_accounts.length}',
      fullName: fullName,
      email: email,
      country: country,
      city: city,
    );
    _accounts[email] = (user: user, password: password);
    return user;
  }
}
