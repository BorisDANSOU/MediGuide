import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/firebase_auth_repository.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Dépôt d'authentification (Firebase Auth). Remplacé par un faux en test.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

/// Utilisateur connecté, `null` pour un visiteur sans compte.
/// Au démarrage, reprend la session gardée par Firebase Auth.
class AuthSession extends Notifier<AppUser?> {
  @override
  AppUser? build() => ref.read(authRepositoryProvider).currentUser;

  void signIn(AppUser user) => state = user;

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = null;
  }
}

final authSessionProvider = NotifierProvider<AuthSession, AppUser?>(
  AuthSession.new,
);
