import 'email_service.dart';

class EmailSendException implements Exception {
  final String message;
  EmailSendException(this.message);
  @override
  String toString() => 'EmailSendException: $message';
}

abstract class EmailSender {
  Future<void> send({
    required String to,
    required String subject,
    required String text,
    required String html,
  });
}

class SmtpEmailSender implements EmailSender {
  final EmailService service;
  SmtpEmailSender(this.service);

  @override
  Future<void> send({
    required String to,
    required String subject,
    required String text,
    required String html,
  }) async {
    try {
      await service.send(to: to, subject: subject, text: text, html: html);
    } catch (e) {
      throw EmailSendException(e.toString());
    }
  }
}

/// Process-wide registry. server.dart sets this on boot; tests substitute
/// via [set] / [reset]. Endpoints read via [get].
class EmailSenderRegistry {
  static EmailSender? _instance;
  static EmailSender? get() => _instance;
  static void set(EmailSender? sender) => _instance = sender;
  static void reset() => _instance = null;
}
