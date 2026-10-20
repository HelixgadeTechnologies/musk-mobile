import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:musk_mover/config/brevo_config.dart';
import 'package:musk_mover/providers/cart_provider.dart';

class BrevoEmailService {
  static const String _brevoApiUrl = 'https://api.brevo.com/v3/smtp/email';

  /// Sends email using either Brevo SMTP Relay (port 587) or Brevo v3 REST API
  static Future<bool> sendEmail({
    required String toEmail,
    required String toName,
    required String subject,
    required String htmlContent,
    List<String>? bccEmails,
  }) async {
    // If neither SMTP password nor API key is configured yet, simulate dispatch in test mode
    if (!BrevoConfig.isConfigured) {
      debugPrint(
        '⚠️ [BrevoEmailService - TEST MODE] Brevo credentials not yet set in brevo_config.dart.\n'
        'Simulating email dispatch to: $toEmail ($toName)\n'
        'Using Brevo Login: ${BrevoConfig.smtpUser}\n'
        'Subject: $subject\n',
      );
      return true;
    }

    // 1. Try Brevo SMTP Relay if smtpPassword is provided
    final hasSmtpKey = BrevoConfig.smtpPassword.isNotEmpty &&
        BrevoConfig.smtpPassword != 'YOUR_BREVO_SMTP_KEY';

    if (hasSmtpKey) {
      try {
        final smtpServer = SmtpServer(
          BrevoConfig.smtpHost,
          port: BrevoConfig.smtpPort,
          username: BrevoConfig.smtpUser,
          password: BrevoConfig.smtpPassword,
          allowInsecure: false,
        );

        final message = Message()
          ..from = Address(BrevoConfig.senderEmail, BrevoConfig.senderName)
          ..recipients.add(Address(toEmail, toName.isNotEmpty ? toName : toEmail))
          ..subject = subject
          ..html = htmlContent;

        if (bccEmails != null && bccEmails.isNotEmpty) {
          final sanitizedBcc = bccEmails
              .where((e) => e.trim().toLowerCase() != toEmail.trim().toLowerCase())
              .toList();
          if (sanitizedBcc.isNotEmpty) {
            message.bccRecipients.addAll(sanitizedBcc.map((e) => Address(e)));
          }
        }

        final report = await send(message, smtpServer);
        debugPrint('✅ [Brevo SMTP] Email delivered successfully to $toEmail. Report: $report');
        return true;
      } catch (smtpError) {
        debugPrint('❌ [Brevo SMTP] Failed to send via SMTP relay: $smtpError');
        debugPrint('💡 [Brevo SMTP Hint] Ensure BrevoConfig.senderEmail ("${BrevoConfig.senderEmail}") is a validated sender in your Brevo account (Senders & IP > Senders).');
        // If REST API key is also available, attempt fallback
        if (BrevoConfig.apiKey.isEmpty ||
            BrevoConfig.apiKey == 'xkeysib-YOUR_BREVO_API_KEY_HERE') {
          return false;
        }
      }
    }

    // 2. Brevo REST API (HTTPS fallback / alternative)
    try {
      final payload = {
        'sender': {
          'name': BrevoConfig.senderName,
          'email': BrevoConfig.senderEmail,
        },
        'to': [
          {
            'email': toEmail,
            'name': toName.isNotEmpty ? toName : toEmail,
          }
        ],
        'subject': subject,
        'htmlContent': htmlContent,
      };

      if (bccEmails != null && bccEmails.isNotEmpty) {
        final sanitizedBcc = bccEmails
            .where((e) => e.trim().toLowerCase() != toEmail.trim().toLowerCase())
            .toList();
        if (sanitizedBcc.isNotEmpty) {
          payload['bcc'] = sanitizedBcc.map((e) => {'email': e}).toList();
        }
      }

      final response = await http.post(
        Uri.parse(_brevoApiUrl),
        headers: {
          'accept': 'application/json',
          'api-key': BrevoConfig.apiKey,
          'content-type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ [Brevo REST API] Email successfully delivered to $toEmail');
        return true;
      } else {
        debugPrint('❌ [Brevo REST API] Failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ [Brevo REST API] Exception while sending email: $e');
      return false;
    }
  }

  /// Sends 4-Digit Email Verification Code for Registration
  static Future<bool> sendRegistrationVerificationOtp({
    required String recipientEmail,
    required String recipientName,
    required String otpCode,
  }) async {
    final html = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: #F8FAFC; margin: 0; padding: 24px; }
    .container { max-width: 560px; margin: 0 auto; background: #ffffff; border-radius: 12px; overflow: hidden; border: 1px solid #E2E8F0; }
    .header { background: #050B20; padding: 28px 24px; text-align: center; }
    .header h1 { color: #ffffff; margin: 0; font-size: 24px; letter-spacing: 2px; }
    .content { padding: 32px 28px; color: #1E293B; line-height: 1.6; }
    .otp-card { background: #F1F5F9; border-radius: 10px; border: 1px dashed #CBD5E1; padding: 24px; text-align: center; margin: 28px 0; }
    .otp-code { font-size: 40px; font-weight: 800; letter-spacing: 14px; color: #050B20; margin: 8px 0; }
    .footer { background: #F8FAFC; padding: 20px; text-align: center; color: #64748B; font-size: 12px; border-top: 1px solid #E2E8F0; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>MUSKMOVER</h1>
    </div>
    <div class="content">
      <h2 style="color: #050B20; margin-top: 0;">Verify Your Email Address</h2>
      <p>Hello <strong>$recipientName</strong>,</p>
      <p>Thank you for creating an account with MuskMover — Nigeria's offshore marine assets & heavy equipment marketplace.</p>
      <p>Please enter the following 4-digit code in the app to verify your corporate account:</p>
      
      <div class="otp-card">
        <div style="font-size: 12px; font-weight: 700; color: #64748B; letter-spacing: 1px; text-transform: uppercase;">Your 4-Digit Verification Code</div>
        <div class="otp-code">$otpCode</div>
        <div style="font-size: 12px; color: #94A3B8;">Code expires in 10 minutes</div>
      </div>

      <p style="font-size: 13px; color: #64748B;">If you did not initiate this registration request, please disregard this email.</p>
    </div>
    <div class="footer">
      &copy; ${DateTime.now().year} MuskMover Technologies Ltd. All rights reserved.<br>
      Offshore Vessels, Marine Logistics & Heavy Industrial Equipment.
    </div>
  </div>
</body>
</html>
''';

    return sendEmail(
      toEmail: recipientEmail,
      toName: recipientName,
      subject: 'Your 4-Digit Verification Code: $otpCode - MuskMover',
      htmlContent: html,
    );
  }

  /// Sends 4-Digit Password Recovery Code for Forgot Password
  static Future<bool> sendPasswordResetOtp({
    required String recipientEmail,
    required String otpCode,
  }) async {
    final html = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: #F8FAFC; margin: 0; padding: 24px; }
    .container { max-width: 560px; margin: 0 auto; background: #ffffff; border-radius: 12px; overflow: hidden; border: 1px solid #E2E8F0; }
    .header { background: #050B20; padding: 28px 24px; text-align: center; }
    .header h1 { color: #ffffff; margin: 0; font-size: 24px; letter-spacing: 2px; }
    .content { padding: 32px 28px; color: #1E293B; line-height: 1.6; }
    .otp-card { background: #FFF7ED; border-radius: 10px; border: 1px dashed #FDBA74; padding: 24px; text-align: center; margin: 28px 0; }
    .otp-code { font-size: 40px; font-weight: 800; letter-spacing: 14px; color: #C2410C; margin: 8px 0; }
    .footer { background: #F8FAFC; padding: 20px; text-align: center; color: #64748B; font-size: 12px; border-top: 1px solid #E2E8F0; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>MUSKMOVER</h1>
    </div>
    <div class="content">
      <h2 style="color: #050B20; margin-top: 0;">Password Recovery Request</h2>
      <p>Hello,</p>
      <p>We received a request to reset the password for your MuskMover account linked to <strong>$recipientEmail</strong>.</p>
      <p>Enter the 4-digit security code below in your mobile app to verify your identity and set a new password:</p>
      
      <div class="otp-card">
        <div style="font-size: 12px; font-weight: 700; color: #9A3412; letter-spacing: 1px; text-transform: uppercase;">Password Reset Code</div>
        <div class="otp-code">$otpCode</div>
        <div style="font-size: 12px; color: #EA580C;">Code valid for 10 minutes</div>
      </div>

      <p style="font-size: 13px; color: #64748B;">If you did not request this password reset, please ignore this email or reach out to our security team immediately.</p>
    </div>
    <div class="footer">
      &copy; ${DateTime.now().year} MuskMover Technologies Ltd. All rights reserved.<br>
      Offshore Vessels, Marine Logistics & Heavy Industrial Equipment.
    </div>
  </div>
</body>
</html>
''';

    return sendEmail(
      toEmail: recipientEmail,
      toName: 'MuskMover Account Holder',
      subject: 'MuskMover Password Reset Code: $otpCode',
      htmlContent: html,
    );
  }

  /// Sends Fleet Quote Enquiry Email with Asset Details & Images
  static Future<bool> sendFleetEnquiryEmail({
    required String customerEmail,
    required String portLocation,
    required String notes,
    required List<CartItem> items,
    required String? Function(CartItem) imageResolver,
  }) async {
    final assetRows = StringBuffer();
    for (final item in items) {
      final img = imageResolver(item);
      final imgTag = (img != null && img.isNotEmpty)
          ? '<img src="$img" alt="${item.name}" width="60" height="60" style="object-fit: cover; border-radius: 6px; border: 1px solid #CBD5E1;" />'
          : '<div style="width: 60px; height: 60px; background: #E2E8F0; border-radius: 6px; text-align: center; line-height: 60px; font-size: 10px; color: #64748B;">NO PHOTO</div>';

      assetRows.write('''
        <tr style="border-bottom: 1px solid #E2E8F0;">
          <td style="padding: 12px; vertical-align: middle;">$imgTag</td>
          <td style="padding: 12px; vertical-align: middle;">
            <strong>${item.name}</strong><br>
            <span style="font-size: 12px; color: #64748B;">${item.info}</span>
          </td>
          <td style="padding: 12px; text-align: center; vertical-align: middle;">
            <span style="background: #F1F5F9; padding: 4px 8px; border-radius: 4px; font-size: 11px; font-weight: bold; color: #050B20;">
              ${item.type.toUpperCase()}
            </span>
          </td>
          <td style="padding: 12px; text-align: center; vertical-align: middle; font-weight: bold;">
            x${item.quantity}
          </td>
        </tr>
      ''');
    }

    final html = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: #F8FAFC; margin: 0; padding: 24px; }
    .container { max-width: 620px; margin: 0 auto; background: #ffffff; border-radius: 12px; overflow: hidden; border: 1px solid #E2E8F0; }
    .header { background: #050B20; padding: 28px 24px; text-align: center; }
    .header h1 { color: #ffffff; margin: 0; font-size: 24px; letter-spacing: 2px; }
    .content { padding: 32px 28px; color: #1E293B; line-height: 1.6; }
    table { width: 100%; border-collapse: collapse; margin-top: 16px; }
    th { background: #F8FAFC; padding: 10px 12px; text-align: left; font-size: 12px; color: #64748B; border-bottom: 2px solid #E2E8F0; }
    .summary-box { background: #F8FAFC; border-radius: 8px; border: 1px solid #E2E8F0; padding: 16px; margin: 20px 0; font-size: 13px; }
    .footer { background: #F8FAFC; padding: 20px; text-align: center; color: #64748B; font-size: 12px; border-top: 1px solid #E2E8F0; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>MUSKMOVER</h1>
    </div>
    <div class="content">
      <h2 style="color: #050B20; margin-top: 0;">Marine Quotation & Fleet Enquiry</h2>
      <p>Thank you for submitting your enquiry. Our commercial fleet desk has logged your request and will provide formal charter rates and specifications shortly.</p>

      <div class="summary-box">
        <strong>Enquiry Overview:</strong><br>
        &bull; <strong>Contact Email:</strong> $customerEmail<br>
        &bull; <strong>Delivery Base / Port:</strong> ${portLocation.isNotEmpty ? portLocation : 'Not Specified'}<br>
        &bull; <strong>Project Requirements:</strong> ${notes.isNotEmpty ? notes : 'Standard charter enquiry'}<br>
        &bull; <strong>Date Submitted:</strong> ${DateTime.now().toLocal().toString().split('.')[0]}
      </div>

      <h3 style="color: #050B20; margin-bottom: 8px;">Requested Assets (${items.length})</h3>
      <table>
        <thead>
          <tr>
            <th>Photo</th>
            <th>Asset Details</th>
            <th style="text-align: center;">Category</th>
            <th style="text-align: center;">Qty</th>
          </tr>
        </thead>
        <tbody>
          $assetRows
        </tbody>
      </table>
    </div>
    <div class="footer">
      &copy; ${DateTime.now().year} MuskMover Technologies Ltd. All rights reserved.<br>
      Offshore Vessels, Marine Logistics & Heavy Industrial Equipment.
    </div>
  </div>
</body>
</html>
''';

    return sendEmail(
      toEmail: customerEmail,
      toName: 'Client',
      subject: 'MuskMover Fleet Enquiry Received - ${items.length} Asset(s)',
      htmlContent: html,
      bccEmails: [BrevoConfig.operationsNotificationEmail],
    );
  }
}
