import 'package:dart_desk_server/src/generated/protocol.dart';
import 'package:dart_desk_server/src/services/app_config.dart';
import 'package:dart_desk_server/src/services/email_sender.dart';
import 'package:dart_desk_server/src/services/invite_email.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../_support/fake_email_sender.dart';

void main() {
  setUp(() {
    AppConfigRegistry.set(const AppConfig(manageBaseUrl: 'https://example.test'));
  });
  tearDown(() {
    AppConfigRegistry.reset();
    EmailSenderRegistry.reset();
  });

  test('sendInviteEmail builds subject + accept URL + body', () async {
    final fake = FakeEmailSender();
    EmailSenderRegistry.set(fake);

    final invite = Invite(
      clientId: UuidValue.fromString('00000000-0000-0000-0000-000000000001'),
      email: 'invitee@example.com',
      role: ClientRole.member,
      token: 'tok123',
      invitedByUserId:
          UuidValue.fromString('00000000-0000-0000-0000-000000000002'),
      expiresAt: DateTime.utc(2026, 6, 1),
    );

    await sendInviteEmail(
      _StubSession(),
      invite: invite,
      clientName: 'Acme',
      inviterName: 'Alice',
      inviterEmail: 'alice@acme.test',
    );

    expect(fake.sent, hasLength(1));
    expect(fake.sent.single.to, 'invitee@example.com');
    expect(fake.sent.single.subject, contains('Acme'));
    expect(fake.sent.single.subject, contains('Alice'));
    expect(
      fake.sent.single.text,
      contains('https://example.test/accept-invite?token=tok123'),
    );
  });

  test('throws when EmailSender not configured', () async {
    EmailSenderRegistry.reset();
    final invite = Invite(
      clientId: UuidValue.fromString('00000000-0000-0000-0000-000000000001'),
      email: 'a@b.co',
      role: ClientRole.member,
      token: 't',
      invitedByUserId:
          UuidValue.fromString('00000000-0000-0000-0000-000000000002'),
      expiresAt: DateTime.utc(2026, 6, 1),
    );
    expect(
      () => sendInviteEmail(
        _StubSession(),
        invite: invite,
        clientName: 'c',
        inviterName: 'i',
        inviterEmail: 'i@b.co',
      ),
      throwsA(isA<EmailSendException>()),
    );
  });
}

class _StubSession implements Session {
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}
