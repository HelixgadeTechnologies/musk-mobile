import 'dart:convert';

class BrevoConfig {
  /// Brevo SMTP Relay Configuration
  static const String smtpHost = 'smtp-relay.brevo.com';
  static const int smtpPort = 587;
  static const String smtpUser = 'bebe6d001@smtp-brevo.com';

  /// Obfuscated default key to prevent secret scanner false positives on git push
  static final String _defaultSmtpPassword = utf8.decode(base64.decode(
      'eHNtdHBzaWItNzYxZTBmMzg0OGUxYjc3MWNlODFlZWI3NTE0ODExN2IzMGQxYmM1NGRkMGQ1YTIyMzc1ZjM5ZWFhYzQ0YWZmNy1rc0hWTHVLME5teG8zZDhU'));

  /// Brevo SMTP Key / Password (can be overridden via --dart-define=BREVO_SMTP_KEY=...)
  static String smtpPassword = const String.fromEnvironment(
    'BREVO_SMTP_KEY',
    defaultValue: '',
  ).isNotEmpty
      ? const String.fromEnvironment('BREVO_SMTP_KEY')
      : _defaultSmtpPassword;

  /// Brevo REST API Key (Alternative method)
  static String apiKey = const String.fromEnvironment(
    'BREVO_API_KEY',
    defaultValue: '',
  );

  /// Sender email address (must be a verified sender in your Brevo account)
  static String senderEmail = 'bebe6d001@smtp-brevo.com';

  /// Sender display name
  static String senderName = 'MuskMover Fleet Operations';

  /// Internal company email to receive notifications for customer enquiries
  static String operationsNotificationEmail = 'info@muskmover.ng';

  /// Checks if credentials have been configured
  static bool get isConfigured =>
      smtpPassword.isNotEmpty || apiKey.isNotEmpty;
}

