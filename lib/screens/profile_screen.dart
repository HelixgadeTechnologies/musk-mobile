import 'package:flutter/material.dart';
import 'package:musk_mover/app_theme.dart';
import 'package:musk_mover/screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('PROFILE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // User Avatar & Name
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.primaryColor,
              child: Icon(Icons.person_rounded, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text('John Doe', style: textTheme.displayMedium?.copyWith(fontSize: 22)),
            Text('Contact Person', style: textTheme.bodyMedium),
            
            const SizedBox(height: 40),
            
            // Personal Information
            _buildInfoCard(
              context,
              title: 'Personal Information',
              items: [
                _buildInfoItem('Phone', '+234 800 123 4567', Icons.phone_android_rounded),
                _buildInfoItem('Email', 'john.doe@musklogistics.com', Icons.email_outlined),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Company Information
            _buildInfoCard(
              context,
              title: 'Company Details',
              items: [
                _buildInfoItem('Legal Name', 'Musk Logistics Ltd', Icons.business_rounded),
                _buildInfoItem('Sector', 'Oil & Gas Logistics', Icons.category_rounded),
                _buildInfoItem('Email', 'office@musklogistics.com', Icons.alternate_email_rounded),
                _buildInfoItem('Phone', '+234 1 234 5678', Icons.phone_rounded),
              ],
            ),
            
            const SizedBox(height: 40),
            
            // Logout Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout_rounded, color: AppTheme.secondaryColor),
                label: const Text('LOG OUT', style: TextStyle(color: AppTheme.secondaryColor)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.secondaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {required String title, required List<Widget> items}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondaryColor,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 20),
          ...items,
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryColor),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondaryColor)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
