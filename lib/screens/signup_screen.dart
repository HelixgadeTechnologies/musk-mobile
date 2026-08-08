import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:musk_mover/app_theme.dart';
import 'package:musk_mover/main.dart';
import 'package:musk_mover/providers/auth_provider.dart';
import 'package:musk_mover/screens/login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  final _contactNameController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _industrySectorController = TextEditingController();
  final _companyEmailController = TextEditingController();
  final _companyPhoneController = TextEditingController();

  @override
  void dispose() {
    _contactNameController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _passwordController.dispose();
    _companyNameController.dispose();
    _industrySectorController.dispose();
    _companyEmailController.dispose();
    _companyPhoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final userData = {
      'contactPersonName': _contactNameController.text.trim(),
      'contactPersonEmail': _contactEmailController.text.trim(),
      'contactPersonPhone': _contactPhoneController.text.trim(),
      'password': _passwordController.text,
      'companyLegalName': _companyNameController.text.trim(),
      'industrySector': _industrySectorController.text.trim(),
      'companyEmail': _companyEmailController.text.trim(),
      'companyPhone': _companyPhoneController.text.trim(),
    };

    final success = await authProvider.register(userData);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Registration failed. Please try again.'),
          backgroundColor: AppTheme.secondaryColor,
        ),
      );
    }
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Company Account',
                  style: textTheme.displayMedium?.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  'Join the premium marine marketplace and manage your fleet operations.',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                
                // Contact Person Group
                _buildSectionTitle('Contact Person Details'),
                const SizedBox(height: 16),
                _buildTextField('Contact Person Name', Icons.person_outline_rounded, controller: _contactNameController, hint: 'Full Name'),
                const SizedBox(height: 16),
                _buildTextField('Contact Person Email', Icons.email_outlined, controller: _contactEmailController, hint: 'person@example.com', keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                _buildTextField('Contact Person Phone', Icons.phone_android_rounded, controller: _contactPhoneController, hint: 'Mobile Number', keyboardType: TextInputType.phone),
                
                const SizedBox(height: 32),
                
                // Security
                _buildSectionTitle('Security'),
                const SizedBox(height: 16),
                Text('Password', style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Minimum 6 characters',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Company Information Group
                _buildSectionTitle('Company Information'),
                const SizedBox(height: 16),
                _buildTextField('Company Legal Name', Icons.business_rounded, controller: _companyNameController, hint: 'e.g. Musk Logistics Ltd'),
                const SizedBox(height: 16),
                _buildTextField('Industry Sector', Icons.category_rounded, controller: _industrySectorController, hint: 'e.g. Oil & Gas, Shipping'),
                const SizedBox(height: 16),
                _buildTextField('Company Email Address', Icons.alternate_email_rounded, controller: _companyEmailController, hint: 'company@example.com', keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                _buildTextField('Company Phone Number', Icons.phone_rounded, controller: _companyPhoneController, hint: '+234...', keyboardType: TextInputType.phone),
                
                const SizedBox(height: 40),
                
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: authProvider.isLoading ? null : _handleSignup,
                        child: authProvider.isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('CREATE ACCOUNT'),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account?'),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        child: const Text(
                          'Sign In',
                          style: TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 10,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    IconData icon, {
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'This field is required';
            }
            if (keyboardType == TextInputType.emailAddress) {
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(value.trim())) {
                return 'Please enter a valid email address';
              }
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
          ),
        ),
      ],
    );
  }
}
