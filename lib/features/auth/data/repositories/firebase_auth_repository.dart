import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import 'firebase_auth_error_messages.dart';

/// Authentification par e-mail et mot de passe avec Firebase Auth.
/// Le pays et la ville sont stockés dans `users/{uid}` (voir firestore.rules).
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  @override
  AppUser? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;
    return AppUser(
      id: user.uid,
      fullName: user.displayName ?? '',
      email: user.email ?? '',
    );
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user!;
      final profile = await _readProfile(user.uid);
      return AppUser(
        id: user.uid,
        fullName: user.displayName ?? profile?['fullName'] as String? ?? '',
        email: user.email ?? email,
        country: profile?['country'] as String?,
        city: profile?['city'] as String?,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(authErrorMessage(e.code));
    }
  }

  @override
  Future<AppUser> signUp({
    required String fullName,
    required String email,
    required String password,
    required String country,
    required String city,
  }) async {
    final UserCredential credential;
    try {
      credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(authErrorMessage(e.code));
    }

    final user = credential.user!;
    // Le compte existe déjà : si l'une des écritures suivantes échoue, on ne
    // bloque pas l'utilisateur. Le pays est aussi gardé localement dans le
    // Profil (selectCountry).
    try {
      await user.updateDisplayName(fullName);
    } on FirebaseAuthException {
      // Le nom reste dans `users/{uid}`.
    }
    try {
      // `set` attend la confirmation du serveur ; hors ligne, l'écriture reste
      // en file d'attente locale (cache Firestore) et part au retour du réseau.
      await _userDoc(user.uid)
          .set({
            'fullName': fullName,
            'email': email,
            'country': country,
            'city': city,
            'createdAt': FieldValue.serverTimestamp(),
          })
          .timeout(const Duration(seconds: 10));
    } on FirebaseException {
      // Règles Firestore ou serveur indisponible.
    } on TimeoutException {
      // Écriture en attente de réseau.
    }
    return AppUser(
      id: user.uid,
      fullName: fullName,
      email: user.email ?? email,
      country: country,
      city: city,
    );
  }

  @override
  Future<void> sendPasswordReset({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(authErrorMessage(e.code));
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  /// Profil Firestore, ou `null` s'il est absent ou illisible (hors ligne).
  Future<Map<String, dynamic>?> _readProfile(String uid) async {
    try {
      return (await _userDoc(uid).get()).data();
    } on FirebaseException {
      return null;
    }
  }
}
