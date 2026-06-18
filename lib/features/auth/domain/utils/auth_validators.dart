/// Validation helpers for authentication inputs.
class AuthValidators {
  AuthValidators._();

  /// Validates a full international phone number.
  /// Returns `null` if valid, otherwise an error message key or raw message.
  static String? validatePhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return 'phone_required';
    }
    final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 7 || digitsOnly.length > 15) {
      return 'phone_invalid';
    }
    return null;
  }

  /// Normalizes a phone number by stripping non-digits and duplicate country codes.
  static String normalizePhone(String countryCode, String localNumber) {
    final codeDigits = countryCode.replaceAll(RegExp(r'\D'), '');
    var numberDigits = localNumber.replaceAll(RegExp(r'\D'), '');

    // Remove leading zero if present (common for local numbers with country code)
    if (numberDigits.startsWith('0')) {
      numberDigits = numberDigits.substring(1);
    }

    // Avoid duplicate country code if user typed it manually
    if (numberDigits.startsWith(codeDigits)) {
      numberDigits = numberDigits.substring(codeDigits.length);
    }

    return '+$codeDigits$numberDigits';
  }

  /// Validates a display name.
  static String? validateDisplayName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'name_required';
    }
    final trimmed = name.trim();
    if (trimmed.length < 2) {
      return 'name_too_short';
    }
    if (trimmed.length > 30) {
      return 'name_too_long';
    }
    return null;
  }

  /// Validates a username.
  /// Allows lowercase letters, digits, and underscores; 3–20 characters.
  static String? validateUsername(String? username) {
    if (username == null || username.trim().isEmpty) {
      return 'username_required';
    }
    var trimmed = username.trim();

    // Strip leading @ if user included it
    if (trimmed.startsWith('@')) {
      trimmed = trimmed.substring(1);
    }

    if (trimmed.length < 3) {
      return 'username_too_short';
    }
    if (trimmed.length > 20) {
      return 'username_too_long';
    }
    if (!RegExp(r'^[a-z0-9_]+$').hasMatch(trimmed.toLowerCase())) {
      return 'username_invalid';
    }
    return null;
  }

  /// Normalizes a username for storage.
  static String normalizeUsername(String username) {
    var trimmed = username.trim();
    if (trimmed.startsWith('@')) {
      trimmed = trimmed.substring(1);
    }
    return trimmed.toLowerCase();
  }
}
