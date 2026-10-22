import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:musk_mover/app_theme.dart';
import 'package:musk_mover/main.dart';
import 'package:musk_mover/providers/auth_provider.dart';
import 'package:musk_mover/screens/reset_password_screen.dart';
import 'package:musk_mover/services/brevo_email_service.dart';

enum OtpFlowType {
  registration,
  forgotPassword,
}

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final String? name;
  final OtpFlowType flowType;
  final String initialOtp;
  final Map<String, dynamic>? registrationData;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    this.name,
    required this.flowType,
    required this.initialOtp,
    this.registrationData,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  late String _currentOtp;
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  late final List<FocusNode> _focusNodes;

  int _resendCountdown = 60;
  Timer? _timer;
  bool _isVerifying = false;
  bool _isResending = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _currentOtp = widget.initialOtp;
    _focusNodes = List.generate(4, (index) {
      return FocusNode(
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace &&
              _controllers[index].text.isEmpty &&
              index > 0) {
            _focusNodes[index - 1].requestFocus();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
      );
    });
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() {
      _resendCountdown = 60;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _enteredCode {
    return _controllers.map((c) => c.text.trim()).join();
  }

  Future<void> _handleResendCode() async {
    if (_resendCountdown > 0 || _isResending) return;

    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    // Generate a fresh 4-digit code
    final newCode = (1000 + Random().nextInt(9000)).toString();
    _currentOtp = newCode;

    bool sent = false;
    if (widget.flowType == OtpFlowType.registration) {
      sent = await BrevoEmailService.sendRegistrationVerificationOtp(
        recipientEmail: widget.email,
        recipientName: widget.name ?? 'Valued Client',
        otpCode: newCode,
      );
    } else {
      sent = await BrevoEmailService.sendPasswordResetOtp(
        recipientEmail: widget.email,
        otpCode: newCode,
      );
    }

    if (!mounted) return;

    setState(() {
      _isResending = false;
    });

    if (sent) {
      _startCountdown();
      for (final c in _controllers) {
        c.clear();
      }
      _focusNodes[0].requestFocus();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('A new 4-digit code has been sent to ${widget.email}'),
          backgroundColor: AppTheme.primaryColor,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to send email. Please check connection and try again.'),
          backgroundColor: AppTheme.secondaryColor,
        ),
      );
    }
  }

  Future<void> _handleVerify() async {
    final code = _enteredCode;
    if (code.length < 4) {
      setState(() {
        _errorMessage = 'Please enter the complete 4-digit code';
      });
      return;
    }

    if (code != _currentOtp) {
      setState(() {
        _errorMessage = 'Incorrect code. Please check your email or resend a new one.';
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    if (widget.flowType == OtpFlowType.registration) {
      // Complete registration with verified email
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.register(widget.registrationData ?? {});

      if (!mounted) return;

      setState(() {
        _isVerifying = false;
      });

      if (success) {
        _showRegistrationSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Registration failed. Please try again.'),
            backgroundColor: AppTheme.secondaryColor,
          ),
        );
      }
    } else {
      // Forgot Password flow -> Navigate to Set New Password screen
      setState(() {
        _isVerifying = false;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordScreen(email: widget.email),
        ),
      );
    }
  }

  void _showRegistrationSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_rounded,
                    color: AppTheme.accentColor,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Account Verified!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your company profile and email have been verified. Welcome to MuskMover Marketplace.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondaryColor,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const MainScreen()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Enter Marketplace', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onDigitChanged(int index, String value) {
    setState(() {
      _errorMessage = null;
    });

    // Handle pasting 4 digits into a single box
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < 4 && i < digits.length; i++) {
        _controllers[i].text = digits[i];
      }
      if (digits.length >= 4) {
        _focusNodes[3].unfocus();
        _handleVerify();
      } else {
        _focusNodes[min(digits.length, 3)].requestFocus();
      }
      return;
    }

    if (value.isNotEmpty) {
      if (index < 3) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        if (_enteredCode.length == 4) {
          _handleVerify();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isRegistration = widget.flowType == OtpFlowType.registration;

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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isRegistration ? Icons.mark_email_read_outlined : Icons.lock_reset_rounded,
                    size: 40,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                isRegistration ? 'Verify Your Email' : 'Enter 4-Digit Code',
                style: textTheme.displayMedium?.copyWith(fontSize: 26),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: textTheme.bodyMedium?.copyWith(height: 1.5),
                  children: [
                    TextSpan(
                      text: isRegistration
                          ? 'We have sent a 4-digit verification code to:\n'
                          : 'A 4-digit password recovery code was sent to:\n',
                    ),
                    TextSpan(
                      text: widget.email,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // 4-Digit Input Boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  return SizedBox(
                    width: 64,
                    height: 70,
                    child: TextFormField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                        ),
                      ),
                      onChanged: (val) => _onDigitChanged(index, val),
                    ),
                  );
                }),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppTheme.secondaryColor, size: 16),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: AppTheme.secondaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 36),

              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _handleVerify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isVerifying
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          isRegistration ? 'Verify & Create Account' : 'Verify & Set Password',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),

              const SizedBox(height: 32),

              // Resend countdown
              Center(
                child: _resendCountdown > 0
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.timer_outlined, size: 16, color: AppTheme.textSecondaryColor),
                          const SizedBox(width: 6),
                          Text(
                            'Resend code in 0:${_resendCountdown.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              color: AppTheme.textSecondaryColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Didn't receive the email? ",
                            style: TextStyle(color: AppTheme.textSecondaryColor, fontSize: 13),
                          ),
                          GestureDetector(
                            onTap: _isResending ? null : _handleResendCode,
                            child: _isResending
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.logoOrange),
                                  )
                                : const Text(
                                    'Resend Code',
                                    style: TextStyle(
                                      color: AppTheme.logoOrange,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Please check your Spam or Junk folder if you do not see the email in your inbox within 1 minute.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
