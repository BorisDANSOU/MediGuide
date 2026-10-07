class ServerException implements Exception {
  const ServerException([this.message = 'Erreur serveur']);

  final String message;
}

class CacheException implements Exception {
  const CacheException([this.message = 'Erreur de cache']);

  final String message;
}
