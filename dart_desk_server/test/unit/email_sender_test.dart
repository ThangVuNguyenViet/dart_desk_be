import 'package:dart_desk_server/src/services/email_sender.dart';
import 'package:test/test.dart';

import '../_support/fake_email_sender.dart';

void main() {
  test('FakeEmailSender records sent messages', () async {
    final sender = FakeEmailSender();
    EmailSenderRegistry.set(sender);

    await EmailSenderRegistry.get()!.send(
      to: 'a@b.co',
      subject: 'hi',
      text: 'plain',
      html: '<p>hi</p>',
    );

    expect(sender.sent, hasLength(1));
    expect(sender.sent.single.to, 'a@b.co');
    expect(sender.sent.single.subject, 'hi');
  });

  test('FakeEmailSender.failNext throws once', () async {
    final sender = FakeEmailSender()..failNext('boom');
    expect(
      () => sender.send(to: 'a@b.co', subject: 's', text: 't', html: '<p>t</p>'),
      throwsA(isA<EmailSendException>()),
    );
    await sender.send(to: 'a@b.co', subject: 's', text: 't', html: '<p>t</p>');
    expect(sender.sent, hasLength(1));
  });
}
