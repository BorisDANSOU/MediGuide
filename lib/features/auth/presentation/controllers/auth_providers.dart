import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/demo_auth_repository.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Dépôt d'authentification. À remplacer par l'implémentation Firebase Auth.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return DemoAuthRepository();
});

/// Utilisateur connecté, `null` pour un visiteur sans compte.
class AuthSession extends Notifier<AppUser?> {
  @override
  AppUser? build() => null;

  void signIn(AppUser user) => state = user;

  void signOut() => state = null;
}

final authSessionProvider = NotifierProvider<AuthSession, AppUser?>(
  AuthSession.new,
);
