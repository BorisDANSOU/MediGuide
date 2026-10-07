/// Règles de saisie partagées par les formulaires (retournent `null` si OK).
class Validators {
  Validators._();

  static final _email = RegExp(r'^[^\s@]+@[^\s@]+\.[a-zA-Z]{2,}$');

  /// Firebase Auth exige au moins 6 caractères ; on en demande 8.
  static const minPasswordLength = 8;

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Saisissez votre adresse e-mail.';
    if (!_email.hasMatch(v)) {
      return 'Adresse e-mail invalide (ex. nom@exemple.com).';
    }
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Saisissez votre mot de passe.';
    if (v.length < minPasswordLength) {
      return 'Au moins $minPasswordLength caractères.';
    }
    return null;
  }

  static String? fullName(String? value) {
    final parts = (value ?? '').trim().split(RegExp(r'\s+'));
    if (parts.length < 2 || parts.any((p) => p.length < 2)) {
      return 'Indiquez votre prénom et votre nom.';
    }
    return null;
  }

  static String? Function(String?) confirmPassword(
    String Function() original,
  ) =>
      (value) => value != original()
      ? 'Les deux mots de passe ne sont pas identiques.'
      : null;
}
