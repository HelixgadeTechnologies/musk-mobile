import 'package:flutter/material.dart';
import 'package:musk_mover/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isSubmitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate sending password reset instructions
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _isSubmitted = true;
    });
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
          child: _isSubmitted ? _buildSuccessView(textTheme) : _buildFormView(textTheme),
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
            'Enter the email address registered with your account. We will send you instructions to reset your password.',
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
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('SEND RESET INSTRUCTIONS'),
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

  Widget _buildSuccessView(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.accentColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            color: AppTheme.accentColor,
            size: 44,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Check Your Email',
          style: textTheme.displayMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: textTheme.bodyMedium?.copyWith(height: 1.5),
            children: [
              const TextSpan(text: 'We have sent password reset instructions to\n'),
              TextSpan(
                text: _emailController.text.trim(),
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
              ),
              const TextSpan(text: '.\nPlease check your inbox and follow the link.'),
            ],
          ),
        ),
        const SizedBox(height: 36),

        // Return to login
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('RETURN TO LOG IN'),
          ),
        ),
        const SizedBox(height: 16),

        // Resend Button
        TextButton.icon(
          onPressed: () {
            setState(() {
              _isSubmitted = false;
            });
          },
          icon: const Icon(Icons.refresh_rounded, size: 18, color: AppTheme.secondaryColor),
          label: const Text(
            'Try another email',
            style: TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
