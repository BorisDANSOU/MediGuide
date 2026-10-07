import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Indique si un utilisateur est déjà connecté
final hasActiveSessionProvider = FutureProvider<bool>((ref) async {
  try {
    final user = await FirebaseAuth.instance.authStateChanges().first.timeout(
      const Duration(seconds: 3),
    );
    return user != null;
  } catch (_) {
    return false;
  }
});
