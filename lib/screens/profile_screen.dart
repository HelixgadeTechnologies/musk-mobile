import 'package:flutter/material.dart';
import 'package:musk_mover/app_theme.dart';
import 'package:musk_mover/screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.primaryColor, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Company Profile', style: TextStyle(color: AppTheme.primaryColor, fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppTheme.primaryColor),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Header Section
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryColor.withValues(alpha: 0.05),
                      border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.1), width: 2),
                    ),
                    child: const Center(
                      child: Icon(Icons.business_rounded, size: 50, color: AppTheme.primaryColor),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Musk Logistics Ltd',
                    style: TextStyle(color: AppTheme.primaryColor, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'VERIFIED ACCOUNT',
                      style: TextStyle(color: AppTheme.textSecondaryColor, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Contact Person Section
            _buildSectionHeader('Contact Person Details'),
            _buildInfoContainer([
              _buildRowItem('Full Name', 'John Doe'),
              _buildDivider(),
              _buildRowItem('Work Email', 'j.doe@musklogistics.com'),
              _buildDivider(),
              _buildRowItem('Phone', '+234 800 123 4567'),
            ]),
            
            const SizedBox(height: 24),
            
            // Company Details Section
            _buildSectionHeader('Company Information'),
            _buildInfoContainer([
              _buildRowItem('Legal Name', 'Musk Logistics Limited'),
              _buildDivider(),
              _buildRowItem('Industry', 'Oil & Gas Services'),
              _buildDivider(),
              _buildRowItem('Company Email', 'info@musklogistics.com'),
              _buildDivider(),
              _buildRowItem('Company Phone', '+234 1 234 5678'),
            ]),
            
            const SizedBox(height: 24),
            
            // Account Section
            _buildSectionHeader('Operations'),
            _buildInfoContainer([
              _buildListItem(Icons.history_rounded, 'Enquiry History'),
              _buildDivider(),
              _buildListItem(Icons.description_outlined, 'Request Documents'),
            ]),
            
            const SizedBox(height: 32),
            
            // Logout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout_rounded, color: AppTheme.secondaryColor, size: 18),
                label: const Text('Sign Out of Company Account', style: TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.bold)),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(color: AppTheme.textSecondaryColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoContainer(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildRowItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondaryColor, fontSize: 14)),
          Text(value, style: const TextStyle(color: AppTheme.primaryColor, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildListItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor, size: 22),
      title: Text(title, style: const TextStyle(color: AppTheme.primaryColor, fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 20),
      onTap: () {},
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFF8FAFC),
      indent: 16,
      endIndent: 16,
    );
  }
}
