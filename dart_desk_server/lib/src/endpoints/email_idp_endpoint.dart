import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:serverpod_auth_idp_server/providers/google.dart';

class EmailIdpEndpoint extends EmailIdpBaseEndpoint {
  @override
  Future<UuidValue> startRegistration(
    Session session, {
    required String email,
  }) async {
    // Check if this email is already registered via Google
    final existingGoogle = await GoogleAccount.db.findFirstRow(
      session,
      where: (t) => t.email.equals(email.toLowerCase()),
    );

    if (existingGoogle != null) {
      throw Exception(
        'This email is already registered via Google. Please sign in with Google instead.',
      );
    }

    return super.startRegistration(session, email: email);
  }
}
