/// Base exception for auth-related failures.
class AuthException implements Exception {
  const AuthException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'AuthException($code): $message';
}

class InvalidPhoneException extends AuthException {
  const InvalidPhoneException()
    : super('Invalid phone number', code: 'INVALID_PHONE');
}

class InvalidOtpException extends AuthException {
  const InvalidOtpException() : super('Invalid OTP code', code: 'INVALID_OTP');
}

class OtpExpiredException extends AuthException {
  const OtpExpiredException() : super('OTP has expired', code: 'OTP_EXPIRED');
}

class ProfileIncompleteException extends AuthException {
  const ProfileIncompleteException()
    : super('Profile is incomplete', code: 'PROFILE_INCOMPLETE');
}
