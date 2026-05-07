import 'package:dart_desk_server/src/generated/protocol.dart';
import 'package:dart_desk_server/src/services/email_sender.dart';
import 'package:test/test.dart';

import '../_support/seed.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('MemberEndpoint invite', (sessionBuilder, endpoints) {
    late _FakeEmailSender fakeMail;

    setUp(() {
      fakeMail = _FakeEmailSender();
      EmailSenderRegistry.set(fakeMail);
    });
    tearDown(() => EmailSenderRegistry.reset());

    group('MemberEndpoint.inviteMember', () {
      test('admin can invite — creates pending row + sends email', () async {
        final ctx = await seedAdminContext(sessionBuilder);

        final result = await endpoints.member.inviteMember(
          ctx.session,
          clientId: ctx.clientId,
          email: 'newmember@example.com',
          role: ClientRole.member,
        );

        expect(result.emailSent, isTrue);
        expect(result.invite.clientId, ctx.clientId);
        expect(result.invite.email, 'newmember@example.com');
        expect(result.invite.role, ClientRole.member);
        expect(result.invite.acceptedAt, isNull);
        expect(result.invite.revokedAt, isNull);
        expect(
            result.invite.expiresAt.isAfter(DateTime.now().toUtc()), isTrue);

        expect(fakeMail.sent, hasLength(1));
        expect(fakeMail.sent.single.to, 'newmember@example.com');
        expect(fakeMail.sent.single.text, contains(result.invite.token));
      });

      test('non-admin → 403', () async {
        final ctx = await seedMemberContext(sessionBuilder);
        await expectLater(
          endpoints.member.inviteMember(
            ctx.session,
            clientId: ctx.clientId,
            email: 'x@y.co',
            role: ClientRole.member,
          ),
          throwsA(isA<ApiException>().having((e) => e.code, 'code', 403)),
        );
      });

      test('inviting role=owner → 400', () async {
        final ctx = await seedAdminContext(sessionBuilder);
        await expectLater(
          endpoints.member.inviteMember(
            ctx.session,
            clientId: ctx.clientId,
            email: 'x@y.co',
            role: ClientRole.owner,
          ),
          throwsA(isA<ApiException>().having((e) => e.code, 'code', 400)),
        );
      });

      test('email already an active member → 409 EMAIL_ALREADY_MEMBER',
          () async {
        final ctx = await seedAdminContext(sessionBuilder);
        final session = sessionBuilder.build();
        await User.db.insertRow(
          session,
          User(
            clientId: ctx.clientId,
            email: 'dup@y.co',
            role: ClientRole.member,
            isActive: true,
          ),
        );
        await expectLater(
          endpoints.member.inviteMember(
            ctx.session,
            clientId: ctx.clientId,
            email: 'dup@y.co',
            role: ClientRole.member,
          ),
          throwsA(isA<ApiException>()
              .having((e) => e.code, 'code', 409)
              .having(
                  (e) => e.errorCode, 'errorCode', 'EMAIL_ALREADY_MEMBER')),
        );
      });

      test('email has pending invite → 409 INVITE_ALREADY_PENDING', () async {
        final ctx = await seedAdminContext(sessionBuilder);
        await endpoints.member.inviteMember(
          ctx.session,
          clientId: ctx.clientId,
          email: 'twice@y.co',
          role: ClientRole.member,
        );
        await expectLater(
          endpoints.member.inviteMember(
            ctx.session,
            clientId: ctx.clientId,
            email: 'twice@y.co',
            role: ClientRole.member,
          ),
          throwsA(isA<ApiException>().having(
              (e) => e.errorCode, 'errorCode', 'INVITE_ALREADY_PENDING')),
        );
      });

      test('email send failure → emailSent=false but invite persisted',
          () async {
        final ctx = await seedAdminContext(sessionBuilder);
        fakeMail.failNext('smtp down');
        final result = await endpoints.member.inviteMember(
          ctx.session,
          clientId: ctx.clientId,
          email: 'fail@y.co',
          role: ClientRole.member,
        );
        expect(result.emailSent, isFalse);
        final session = sessionBuilder.build();
        final found = await Invite.db.findById(session, result.invite.id);
        expect(found, isNotNull);
      });
    });

    group('MemberEndpoint.listPendingInvites', () {
      test('returns only non-accepted/non-revoked/non-expired', () async {
        final ctx = await seedAdminContext(sessionBuilder);
        final session = sessionBuilder.build();

        await endpoints.member.inviteMember(
          ctx.session,
          clientId: ctx.clientId,
          email: 'live@y.co',
          role: ClientRole.member,
        );
        final revoked = await endpoints.member.inviteMember(
          ctx.session,
          clientId: ctx.clientId,
          email: 'rev@y.co',
          role: ClientRole.member,
        );
        await endpoints.member
            .revokeInvite(ctx.session, inviteId: revoked.invite.id);

        // Manually expire one.
        final expired = await endpoints.member.inviteMember(
          ctx.session,
          clientId: ctx.clientId,
          email: 'exp@y.co',
          role: ClientRole.member,
        );
        final expiredRow =
            (await Invite.db.findById(session, expired.invite.id))!;
        expiredRow.expiresAt =
            DateTime.now().toUtc().subtract(const Duration(days: 1));
        await Invite.db.updateRow(session, expiredRow);

        final list = await endpoints.member
            .listPendingInvites(ctx.session, clientId: ctx.clientId);
        expect(list.map((i) => i.email), contains('live@y.co'));
        expect(list.map((i) => i.email), isNot(contains('rev@y.co')));
        expect(list.map((i) => i.email), isNot(contains('exp@y.co')));
      });
    });

    group('MemberEndpoint.resendInvite', () {
      test('bumps expiresAt and re-sends email', () async {
        final ctx = await seedAdminContext(sessionBuilder);
        final session = sessionBuilder.build();

        final created = await endpoints.member.inviteMember(
          ctx.session,
          clientId: ctx.clientId,
          email: 'r@y.co',
          role: ClientRole.member,
        );
        fakeMail.sent.clear();

        // Backdate so the bump is observable.
        final row = (await Invite.db.findById(session, created.invite.id))!;
        row.expiresAt = DateTime.now().toUtc().add(const Duration(days: 1));
        await Invite.db.updateRow(session, row);

        final resent = await endpoints.member
            .resendInvite(ctx.session, inviteId: created.invite.id);
        expect(resent.emailSent, isTrue);
        expect(resent.invite.expiresAt.isAfter(row.expiresAt), isTrue);
        expect(fakeMail.sent, hasLength(1));
      });

      test('refuses to resend revoked invite', () async {
        final ctx = await seedAdminContext(sessionBuilder);
        final created = await endpoints.member.inviteMember(
          ctx.session,
          clientId: ctx.clientId,
          email: 'r2@y.co',
          role: ClientRole.member,
        );
        await endpoints.member
            .revokeInvite(ctx.session, inviteId: created.invite.id);
        await expectLater(
          endpoints.member
              .resendInvite(ctx.session, inviteId: created.invite.id),
          throwsA(isA<ApiException>()
              .having((e) => e.errorCode, 'errorCode', 'INVITE_REVOKED')),
        );
      });
    });

    group('MemberEndpoint.revokeInvite', () {
      test('sets revokedAt', () async {
        final ctx = await seedAdminContext(sessionBuilder);
        final session = sessionBuilder.build();

        final created = await endpoints.member.inviteMember(
          ctx.session,
          clientId: ctx.clientId,
          email: 'rv@y.co',
          role: ClientRole.member,
        );
        await endpoints.member
            .revokeInvite(ctx.session, inviteId: created.invite.id);
        final row = (await Invite.db.findById(session, created.invite.id))!;
        expect(row.revokedAt, isNotNull);
      });
    });
  });
}

// ---------------------------------------------------------------------------
// Minimal fake email sender local to this test file.
// ---------------------------------------------------------------------------

class _SentEmail {
  final String to, subject, text, html;
  _SentEmail(
      {required this.to,
      required this.subject,
      required this.text,
      required this.html});
}

class _FakeEmailSender implements EmailSender {
  final List<_SentEmail> sent = [];
  String? _failNextMessage;

  void failNext(String message) => _failNextMessage = message;

  @override
  Future<void> send({
    required String to,
    required String subject,
    required String text,
    required String html,
  }) async {
    if (_failNextMessage != null) {
      final msg = _failNextMessage!;
      _failNextMessage = null;
      throw EmailSendException(msg);
    }
    sent.add(_SentEmail(to: to, subject: subject, text: text, html: html));
  }
}
