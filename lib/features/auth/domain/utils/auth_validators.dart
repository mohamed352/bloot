/// Validation helpers for authentication inputs.
class AuthValidators {
  AuthValidators._();

  /// Validates a display name.
  /// Returns `null` if valid, otherwise an error message key or raw message.
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
