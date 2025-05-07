import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  static Future<bool> sendEmail({
    required String recipientEmail,
    required String subject,
    required String body,
  }) async {
    final smtpServer = SmtpServer(
      'smtp.gmail.com',
      port: 587,
      username: 'artisandz.contact@gmail.com',
      password: 'hprs mhes hhzq bxal',
    );

    final message = Message()
      ..from = Address('artisandz.contact@gmail.com', 'Artisans DZ Support')
      ..recipients.add(recipientEmail)
      ..subject = subject
      ..text = body;

    try {
      final sendReport = await send(message, smtpServer);
      return true;
    } catch (e) {
      return false;
    }
  }
}
