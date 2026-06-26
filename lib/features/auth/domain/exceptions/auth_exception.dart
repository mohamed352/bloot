/// Base exception for auth-related failures.
class AuthException implements Exception {
  const AuthException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'AuthException($code): $message';
}

class ProfileIncompleteException extends AuthException {
  const ProfileIncompleteException()
    : super('Profile is incomplete', code: 'PROFILE_INCOMPLETE');
}
