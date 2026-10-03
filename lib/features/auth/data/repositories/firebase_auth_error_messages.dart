/// Traduit un code d'erreur Firebase Auth en message lisible.
/// Codes : https://firebase.google.com/docs/reference/js/auth#autherrorcodes
String authErrorMessage(String code) => switch (code) {
  'invalid-email' => 'Adresse e-mail invalide.',
  'email-already-in-use' => 'Un compte existe déjà avec cet e-mail.',
  'weak-password' => 'Mot de passe trop faible. Choisissez-en un plus long.',
  // Depuis la protection contre l'énumération des e-mails, Firebase répond
  // `invalid-credential` sans dire si l'e-mail existe.
  'invalid-credential' ||
  'wrong-password' ||
  'user-not-found' => 'E-mail ou mot de passe incorrect.',
  'user-disabled' => 'Ce compte a été désactivé.',
  'too-many-requests' =>
    'Trop de tentatives. Patientez quelques minutes avant de réessayer.',
  'network-request-failed' =>
    'Pas de connexion Internet. Vérifiez votre réseau et réessayez.',
  'operation-not-allowed' =>
    'La connexion par e-mail n’est pas encore activée sur le serveur.',
  _ => 'Une erreur est survenue. Réessayez plus tard.',
};
