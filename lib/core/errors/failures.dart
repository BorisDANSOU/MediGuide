abstract class Failure {
  const Failure(this.message);

  final String message;
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Une erreur serveur est survenue.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Impossible de lire le cache local.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Vérifiez votre connexion internet.']);
}
