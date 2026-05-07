import 'package:dart_desk_server/src/services/email_sender.dart';

class SentEmail {
  final String to, subject, text, html;
  SentEmail({required this.to, required this.subject, required this.text, required this.html});
}

class FakeEmailSender implements EmailSender {
  final List<SentEmail> sent = [];
  String? _failNextMessage;

  void failNext(String message) {
    _failNextMessage = message;
  }

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
    sent.add(SentEmail(to: to, subject: subject, text: text, html: html));
  }
}
