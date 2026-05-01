import 'package:flutter/material.dart';
import 'package:musk_mover/app_theme.dart';
import 'package:musk_mover/screens/login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

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
                
                // Company Information Group
                _buildSectionTitle('Company Information'),
                const SizedBox(height: 16),
                _buildTextField('Company Legal Name', Icons.business_rounded, hint: 'e.g. Musk Logistics Ltd'),
                const SizedBox(height: 16),
                _buildTextField('Industry Sector', Icons.category_rounded, hint: 'e.g. Oil & Gas, Shipping'),
                const SizedBox(height: 16),
                _buildTextField('Company Email Address', Icons.alternate_email_rounded, hint: 'company@example.com', keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                _buildTextField('Company Phone Number', Icons.phone_rounded, hint: '+234...', keyboardType: TextInputType.phone),
                
                const SizedBox(height: 32),
                
                // Contact Person Group
                _buildSectionTitle('Contact Person Details'),
                const SizedBox(height: 16),
                _buildTextField('Contact Person Name', Icons.person_outline_rounded, hint: 'Full Name'),
                const SizedBox(height: 16),
                _buildTextField('Contact Person Email', Icons.email_outlined, hint: 'person@example.com', keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                _buildTextField('Contact Person Phone', Icons.phone_android_rounded, hint: 'Mobile Number', keyboardType: TextInputType.phone),
                
                const SizedBox(height: 32),
                
                // Security
                _buildSectionTitle('Security'),
                const SizedBox(height: 16),
                Text('Password', style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Minimum 8 characters',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                ElevatedButton(
                  onPressed: () {
                    // Logic to handle signup
                  },
                  child: const Text('CREATE ACCOUNT'),
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

  Widget _buildTextField(String label, IconData icon, {String? hint, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
          ),
        ),
      ],
    );
  }
}
