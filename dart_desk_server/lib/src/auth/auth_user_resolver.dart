import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:serverpod_auth_idp_server/providers/google.dart';

/// Returns the [UuidValue] of the [AuthUser] whose registered email matches
/// [email], searching across both the email IDP and the Google IDP.
///
/// Returns `null` if no matching [AuthUser] exists in either store.
///
/// The lookup is case-insensitive: [email] is lower-cased before comparing,
/// mirroring the storage convention used by both IDPs (both store emails in
/// lower-case).
Future<UuidValue?> findAuthUserIdByEmail(
  Session session,
  String email, {
  Transaction? transaction,
}) async {
  final normalised = email.toLowerCase();

  // 1. Check the email IDP store.
  final emailAccount = await EmailAccount.db.findFirstRow(
    session,
    where: (t) => t.email.equals(normalised),
    transaction: transaction,
  );
  if (emailAccount != null) return emailAccount.authUserId;

  // 2. Check the Google IDP store.
  final googleAccount = await GoogleAccount.db.findFirstRow(
    session,
    where: (t) => t.email.equals(normalised),
    transaction: transaction,
  );
  if (googleAccount != null) return googleAccount.authUserId;

  return null;
}
