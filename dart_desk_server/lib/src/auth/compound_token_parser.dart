/// Parses the compound token format used by the custom authentication handler.
///
/// Tokens may be:
/// - A plain JWT: `eyJhbGciOi...`
/// - A compound JWT + API key: `eyJhbGciOi...:cms_w_abc123`
/// - A plain API key (rare, used by automated clients): `cms_w_abc123`
class CompoundTokenParser {
  final String? jwtToken;
  final String? apiKey;

  const CompoundTokenParser._({this.jwtToken, this.apiKey});

  /// Parse a raw authorization token into its JWT and API key components.
  ///
  /// When the token contains a `:` separator, the left side is the JWT and
  /// the right side is the API key. A plain token (no `:`) starting with
  /// `cms_` is treated as an API key; otherwise it's treated as a JWT.
  static CompoundTokenParser parse(String token) {
    final colonIndex = token.indexOf(':');
    if (colonIndex == -1) {
      if (token.startsWith('cms_')) {
        return CompoundTokenParser._(apiKey: token);
      }
      return CompoundTokenParser._(jwtToken: token);
    }

    final left = token.substring(0, colonIndex);
    final right = token.substring(colonIndex + 1);

    return CompoundTokenParser._(
      jwtToken: left.isNotEmpty ? left : null,
      apiKey: right.isNotEmpty ? right : null,
    );
  }
}
