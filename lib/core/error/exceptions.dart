class ServerException implements Exception {
  const ServerException([this.message = 'A server error occurred.']);
  final String message;
}

class CacheException implements Exception {
  const CacheException([this.message = 'A local storage error occurred.']);
  final String message;
}
