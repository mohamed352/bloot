import 'dart:convert';

abstract class AppExtraCodec {
  static Map<String, dynamic>? decodeExtra(String? encoded) {
    if (encoded == null) return null;
    try {
      final Object? decoded = jsonDecode(encoded);
      if (decoded is Map<String, dynamic>) return decoded;
    } on FormatException {
      return null;
    }
    return null;
  }

  static String? encodeExtra(Map<String, dynamic>? extra) {
    if (extra == null) return null;
    return jsonEncode(extra);
  }
}
