import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  // Credentials provided by user
  final String _username = 'canedoalbert6@gmail.com'; 
  final String _password = 'jwepxeadlwtcqhlx'; 

  Future<bool> sendOtpEmail(String recipientEmail, String otp) async {
    final smtpServer = gmail(_username, _password);
    final timestamp = DateTime.now().toLocal().toString().split('.')[0];

    final message = Message()
      ..from = Address(_username, 'CipherTask Security')
      ..recipients.add(recipientEmail)
      ..subject = '🔐 CipherTask Login Code: $otp'
      ..text = 'LOGIN NOTIFICATION\n'
          '----------------------------------------\n'
          'Your Login Verification Code: $otp\n'
          'Time: $timestamp\n'
          '----------------------------------------\n'
          'This code will expire in 10 minutes.\n'
          'If you did not request this code, please ignore this email.'
      ..html = """
        <div style="font-family: 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: #f0f4f8; padding: 50px 20px; color: #1a202c; line-height: 1.5;">
          <div style="max-width: 500px; margin: 0 auto; background: #ffffff; border-radius: 16px; overflow: hidden; box-shadow: 0 10px 25px rgba(0,0,0,0.1); border: 1px solid #e2e8f0;">
            
            <!-- Header -->
            <div style="background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%); padding: 40px 30px; text-align: center;">
              <div style="display: inline-block; background: rgba(255,255,255,0.1); padding: 12px; border-radius: 12px; margin-bottom: 16px;">
                <span style="font-size: 32px;">🛡️</span>
              </div>
              <h1 style="color: #ffffff; margin: 0; font-size: 26px; letter-spacing: 0.5px; font-weight: 700;">CipherTask</h1>
              <p style="color: #94a3b8; margin: 8px 0 0; font-size: 14px; text-transform: uppercase; letter-spacing: 2px;">Secure Storage</p>
            </div>

            <!-- Body -->
            <div style="padding: 40px 35px; text-align: center;">
              <h2 style="margin-top: 0; color: #0f172a; font-size: 22px; font-weight: 600;">Login Code</h2>
              <p style="color: #4a5568; margin-bottom: 32px; font-size: 16px;">Enter this code in the app to log in.</p>
              
              <!-- OTP Box -->
              <div style="background-color: #f8fafc; border: 2px solid #e2e8f0; border-radius: 12px; padding: 30px; margin-bottom: 32px; position: relative;">
                <span style="display: block; font-size: 42px; font-weight: 800; color: #2563eb; letter-spacing: 8px; font-family: 'Courier New', Courier, monospace;">$otp</span>
              </div>

              <p style="font-size: 14px; color: #718096; margin-bottom: 0;">
                This code works for <strong>10 minutes</strong>.
              </p>
              <div style="margin-top: 12px; font-size: 12px; color: #a0aec0;">
                Created at: $timestamp
              </div>
            </div>

            <!-- Warning/Footer -->
            <div style="background-color: #fdf2f2; border-top: 1px solid #fee2e2; padding: 25px 35px;">
              <div style="display: flex; align-items: flex-start;">
                <div style="margin-right: 12px; font-size: 18px;">⚠️</div>
                <p style="font-size: 12px; color: #9b1c1c; margin: 0; line-height: 1.4;">
                  <strong>Safety Note:</strong> If you did not ask for this code, someone else might be trying to log in. Please ignore this email and do not share this code with anyone.
                </p>
              </div>
            </div>

            <div style="background-color: #ffffff; padding: 20px 35px; text-align: center; border-top: 1px solid #edf2f7;">
              <p style="font-size: 12px; color: #cbd5e0; margin: 0;">
                &copy; ${DateTime.now().year} CipherTask. All rights reserved.
              </p>
            </div>

          </div>
        </div>
      """;

    try {
      print('Attempting to send simplified OTP email to $recipientEmail...');
      await send(message, smtpServer);
      print('Email sent successfully!');
      return true;
    } on MailerException catch (e) {
      print('Failed to send email: $e');
      return false;
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }
}
