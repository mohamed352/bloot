/// Agora configuration constants.
///
/// The App ID is a public credential embedded in the client.
/// The App Certificate is NEVER stored here — it lives only in
/// Cloud Functions environment variables for token generation.
abstract class AgoraConfig {
  AgoraConfig._();

  /// Agora App ID (public, client-side).
  static const String appId = 'bb870f5245d24edc8da330c2c86ad0ae';

  /// Token expiry in seconds (24 hours).
  static const int tokenExpirySeconds = 3600 * 24;
}
