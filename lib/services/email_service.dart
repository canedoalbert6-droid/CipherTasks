import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  // These should ideally be in a secure config or .env
  final String _username = ''; 
  final String _password = ''; 

  Future<bool> sendOtpEmail(String recipientEmail, String otp) async {
    final smtpServer = gmail(_username, _password);

    final message = Message()
      ..from = Address(_username, 'CipherTask Security')
      ..recipients.add(recipientEmail)
      ..subject = 'CipherTask Security Authorization'
      ..text = 'SECURITY NOTIFICATION\n'
          '----------------------------------------\n'
          'Your OTP Authorization Code: $otp\n'
          'Timestamp: ${DateTime.now().toIso8601String()}\n'
          '----------------------------------------\n'
          'This code will expire in 10 minutes.\n'
          'If you did not request this code, please ignore this email.';

    try {
      await send(message, smtpServer);
      return true;
    } on MailerException catch (_) {
      return false;
    }
  }
}
