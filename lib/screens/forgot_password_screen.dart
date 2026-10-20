import 'dart:math';
import 'package:flutter/material.dart';
import 'package:musk_mover/app_theme.dart';
import 'package:musk_mover/screens/otp_verification_screen.dart';
import 'package:musk_mover/services/brevo_email_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();

    setState(() {
      _isLoading = true;
    });

    // Generate 4-digit recovery code
    final otpCode = (1000 + Random().nextInt(9000)).toString();

    // Send password reset email via Brevo
    final sent = await BrevoEmailService.sendPasswordResetOtp(
      recipientEmail: email,
      otpCode: otpCode,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (!sent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not send recovery code email. Please check your connection and try resending on the next screen.'),
          backgroundColor: AppTheme.secondaryColor,
        ),
      );
    }

    // Navigate to 4-digit code verification page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OtpVerificationScreen(
          email: email,
          flowType: OtpFlowType.forgotPassword,
          initialOtp: otpCode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: _buildFormView(textTheme),
        ),
      ),
    );
  }

  Widget _buildFormView(TextTheme textTheme) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Center(
            child: Image.asset(
              'assets/images/logo.png',
              height: 70,
            ),
          ),
          const SizedBox(height: 36),
          Text(
            'Forgot Password',
            style: textTheme.displayMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the email address registered with your account. We will send you a 4-digit verification code to reset your password.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 36),

          // Email field
          Text(
            'Email Address',
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                return 'Please enter a valid email address';
              }
              return null;
            },
            decoration: const InputDecoration(
              hintText: 'name@example.com',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 36),

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleResetPassword,
              child: _isLoading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('SENDING CODE...'),
                      ],
                    )
                  : const Text('SEND 4-DIGIT CODE'),
            ),
          ),
          const SizedBox(height: 28),

          // Back to Login Link
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Remember your password?'),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Log In',
                    style: TextStyle(
                      color: AppTheme.secondaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
