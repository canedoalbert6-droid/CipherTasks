import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  final String _smtpServer = 'smtp.gmail.com';
  final int _port = 587;
  
  // These should ideally be in a secure config or .env
  final String _username = 'canedoalbert6@gmail.com'; 
  final String _password = 'kkmgfcjpylnghdqa'; 

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
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
      return true;
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
      return false;
    }
  }
}
