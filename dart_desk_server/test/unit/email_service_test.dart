import 'package:dart_desk_server/src/services/email_service.dart';
import 'package:test/test.dart';

void main() {
  group('SmtpConfig', () {
    test('stores all fields correctly', () {
      final config = SmtpConfig(
        host: 'smtp.example.com',
        port: 587,
        username: 'user@example.com',
        password: 'secret',
        fromAddress: 'noreply@example.com',
        fromName: 'Test App',
      );

      expect(config.host, 'smtp.example.com');
      expect(config.port, 587);
      expect(config.username, 'user@example.com');
      expect(config.password, 'secret');
      expect(config.fromAddress, 'noreply@example.com');
      expect(config.fromName, 'Test App');
    });
  });

  group('EmailService', () {
    test('send throws on invalid SMTP host', () async {
      final service = EmailService(SmtpConfig(
        host: 'invalid.host.that.does.not.exist.example',
        port: 587,
        username: 'user',
        password: 'pass',
        fromAddress: 'from@example.com',
        fromName: 'Test',
      ));

      await expectLater(
        service.send(
          to: 'to@example.com',
          subject: 'Test',
          text: 'body',
          html: '<p>body</p>',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
