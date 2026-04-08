import 'package:mailer/mailer.dart' as mailer;
import 'package:mailer/smtp_server.dart';

/// Configuration for connecting to an SMTP server.
class SmtpConfig {
  final String host;
  final int port;
  final String username;
  final String password;
  final String fromAddress;
  final String fromName;

  const SmtpConfig({
    required this.host,
    required this.port,
    required this.username,
    required this.password,
    required this.fromAddress,
    required this.fromName,
  });
}

/// Sends emails via SMTP. Extracted for testability.
class EmailService {
  final SmtpConfig config;

  const EmailService(this.config);

  /// Sends an email. Throws on failure.
  Future<void> send({
    required String to,
    required String subject,
    required String text,
    required String html,
  }) async {
    final smtpServer = SmtpServer(
      config.host,
      port: config.port,
      username: config.username,
      password: config.password,
    );

    final message = mailer.Message()
      ..from = mailer.Address(config.fromAddress, config.fromName)
      ..recipients.add(to)
      ..subject = subject
      ..text = text
      ..html = html;

    await mailer.send(message, smtpServer);
  }
}
