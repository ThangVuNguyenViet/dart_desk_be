/// Holds validated API key information for the current request.
class ApiKeyContext {
  final int? clientId;
  final String role; // 'read' or 'write'
  final int tokenId;

  const ApiKeyContext({
    required this.clientId,
    required this.role,
    required this.tokenId,
  });

  bool get canWrite => role == 'write';
  bool get canRead => true; // both roles can read
}
