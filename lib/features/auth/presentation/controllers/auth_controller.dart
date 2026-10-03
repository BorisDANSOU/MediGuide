import 'package:flutter/foundation.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_up.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._signIn, this._signUp);

  final SignIn _signIn;
  final SignUp _signUp;

  bool _busy = false;
  String? _error;

  bool get busy => _busy;
  String? get error => _error;

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  /// Retourne l'utilisateur, ou `null` en cas d'échec (voir [error]).
  Future<AppUser?> signIn({required String email, required String password}) =>
      _run(() => _signIn(email: email, password: password));

  Future<AppUser?> signUp({
    required String fullName,
    required String email,
    required String password,
    required String country,
    required String city,
  }) => _run(
    () => _signUp(
      fullName: fullName,
      email: email,
      password: password,
      country: country,
      city: city,
    ),
  );

  Future<AppUser?> _run(Future<AppUser> Function() action) async {
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      return await action();
    } on AuthFailure catch (e) {
      _error = e.message;
      return null;
    } catch (_) {
      _error = 'Une erreur est survenue. Vérifiez votre connexion.';
      return null;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}
