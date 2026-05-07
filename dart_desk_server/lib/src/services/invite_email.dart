import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'app_config.dart';
import 'email_sender.dart';

/// Sends the invite email. On SMTP failure throws [EmailSendException]
/// (caller decides whether to swallow). Returns silently on success.
Future<void> sendInviteEmail(
  Session session, {
  required Invite invite,
  required String clientName,
  required String inviterName,
  required String inviterEmail,
}) async {
  final sender = EmailSenderRegistry.get();
  if (sender == null) {
    throw EmailSendException('EmailSender not configured');
  }
  final baseUrl =
      AppConfigRegistry.get()?.manageBaseUrl ?? 'https://manage.dartdesk.dev';
  final acceptUrl = '$baseUrl/accept-invite?token=${invite.token}';
  final roleName = invite.role.name;
  final expires = invite.expiresAt.toUtc().toIso8601String();

  final subject = '$inviterName invited you to $clientName on Dart Desk';
  final text = '''
You've been invited to $clientName.

$inviterName ($inviterEmail) invited you to join the $clientName workspace
on Dart Desk as a $roleName.

Accept the invite: $acceptUrl

This link expires on $expires (UTC). If you didn't expect this email, you
can ignore it.
''';
  final html = '''
<p>You've been invited to <strong>$clientName</strong>.</p>
<p>$inviterName (<a href="mailto:$inviterEmail">$inviterEmail</a>) invited you
to join the <strong>$clientName</strong> workspace on Dart Desk as a
<strong>$roleName</strong>.</p>
<p><a href="$acceptUrl">Accept the invite</a></p>
<p style="color:#666;font-size:12px">This link expires on $expires (UTC).
If you didn't expect this email, you can ignore it.</p>
''';

  await sender.send(to: invite.email, subject: subject, text: text, html: html);
}
