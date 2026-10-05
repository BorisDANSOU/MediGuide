import 'package:mediguid/features/auth/domain/entities/app_user.dart';
import 'package:mediguid/features/auth/domain/repositories/auth_repository.dart';

/// Authentification en mémoire pour les tests (remplace Firebase Auth).
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({AppUser? signedIn}) : _current = signedIn;

  static const knownEmail = 'awa@exemple.bf';
  static const knownPassword = 'motdepasse';

  final Map<String, ({AppUser user, String password})> _accounts = {
    knownEmail: (
      user: const AppUser(
        id: 'awa',
        fullName: 'Awa Ouédraogo',
        email: knownEmail,
        country: 'Burkina Faso',
        city: 'Ouagadougou',
      ),
      password: knownPassword,
    ),
  };
  AppUser? _current;
  final List<String> resetEmails = [];

  @override
  AppUser? get currentUser => _current;

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final account = _accounts[email];
    if (account == null || account.password != password) {
      throw const AuthFailure('E-mail ou mot de passe incorrect.');
    }
    return _current = account.user;
  }

  @override
  Future<AppUser> signUp({
    required String fullName,
    required String email,
    required String password,
    required String country,
    required String city,
  }) async {
    if (_accounts.containsKey(email)) {
      throw const AuthFailure('Un compte existe déjà avec cet e-mail.');
    }
    final user = AppUser(
      id: 'u${_accounts.length}',
      fullName: fullName,
      email: email,
      country: country,
      city: city,
    );
    _accounts[email] = (user: user, password: password);
    return _current = user;
  }

  @override
  Future<void> sendPasswordReset({required String email}) async {
    resetEmails.add(email);
  }

  @override
  Future<void> signOut() async => _current = null;
}
