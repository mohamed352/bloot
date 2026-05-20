/// Base exception for discover-related failures.
class DiscoverException implements Exception {
  const DiscoverException(this.message);

  final String message;
}
