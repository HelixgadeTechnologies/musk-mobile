import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:musk_mover/app_theme.dart';
import 'package:musk_mover/providers/auth_provider.dart';
import 'package:musk_mover/screens/login_screen.dart';
import 'package:musk_mover/screens/enquiry_history_screen.dart';
import 'package:musk_mover/screens/edit_profile_screen.dart';
import 'package:musk_mover/providers/enquiry_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback? onBackToHome;

  const ProfileScreen({super.key, this.onBackToHome});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    final contactName = user?['contactPersonName'] ?? user?['contactName'] ?? 'John Doe';
    final email = user?['contactPersonEmail'] ?? user?['email'] ?? 'j.doe@musklogistics.com';
    final contactPhone = user?['contactPersonPhone'] ?? user?['contactPhone'] ?? '+234 800 123 4567';
    final companyName = user?['companyLegalName'] ?? user?['companyName'] ?? 'Musk Logistics Ltd';
    final industrySector = user?['industrySector'] ?? 'Oil & Gas Services';
    final companyEmail = user?['companyEmail'] ?? 'info@musklogistics.com';
    final companyPhone = user?['companyPhone'] ?? '+234 1 234 5678';
    final companyAddress = user?['companyAddress'] ??
        user?['address'] ??
        user?['deliveryBase'] ??
        'Federal Ocean Terminal, Onne Port, Rivers State';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.primaryColor, size: 20),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else if (onBackToHome != null) {
              onBackToHome!();
            }
          },
        ),
        title: const Text('Company Profile', style: TextStyle(color: AppTheme.primaryColor, fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppTheme.primaryColor),
            tooltip: 'Edit Profile',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const EditProfileScreen()),
              );
            },
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
                  Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryColor.withValues(alpha: 0.05),
                          border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.1), width: 2),
                        ),
                        child: ClipOval(
                          child: _buildAvatarImage(authProvider.profileImage, size: 100),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    companyName,
                    style: const TextStyle(color: AppTheme.primaryColor, fontSize: 22, fontWeight: FontWeight.bold),
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
              _buildRowItem('Full Name', contactName),
              _buildDivider(),
              _buildRowItem('Work Email', email),
              _buildDivider(),
              _buildRowItem('Phone', contactPhone),
            ]),
            
            const SizedBox(height: 24),
            
            // Company Details Section
            _buildSectionHeader('Company Information'),
            _buildInfoContainer([
              _buildRowItem('Legal Name', companyName),
              _buildDivider(),
              _buildRowItem('Industry', industrySector),
              _buildDivider(),
              _buildRowItem('Company Email', companyEmail),
              _buildDivider(),
              _buildRowItem('Company Phone', companyPhone),
              _buildDivider(),
              _buildRowItem('Delivery Base / Address', companyAddress),
            ]),
            
            const SizedBox(height: 24),
            
            // Operations Section
            _buildSectionHeader('Operations'),
            _buildInfoContainer([
              _buildListItem(
                Icons.history_rounded,
                'Enquiry History',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const EnquiryHistoryScreen(),
                    ),
                  );
                },
              ),
            ]),

            const SizedBox(height: 24),

            // Privacy & Policy Section (Play Store Requirement)
            _buildSectionHeader('Privacy & Legal'),
            _buildInfoContainer([
              _buildListItem(
                Icons.privacy_tip_outlined,
                'Privacy Policy',
                onTap: () => _launchWebUrl(context, 'https://muskmover.ng/privacy'),
              ),
              _buildDivider(),
              _buildListItem(
                Icons.description_outlined,
                'Terms of Service',
                onTap: () => _launchWebUrl(context, 'https://muskmover.ng/terms'),
              ),
            ]),

            const SizedBox(height: 24),

            // Account Deletion Section (Play Store Requirement)
            _buildSectionHeader('Account Management'),
            _buildInfoContainer([
              _buildListItem(
                Icons.delete_forever_rounded,
                'Delete Account & Data',
                isDestructive: true,
                onTap: () => _showDeleteAccountDialog(context, authProvider),
              ),
            ]),
            
            const SizedBox(height: 32),
            
            // Logout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextButton.icon(
                onPressed: () async {
                  await authProvider.logout();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  }
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
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(color: AppTheme.primaryColor, fontSize: 14, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(
    IconData icon,
    String title, {
    VoidCallback? onTap,
    Color? color,
    bool isDestructive = false,
  }) {
    final itemColor = color ?? (isDestructive ? AppTheme.secondaryColor : AppTheme.primaryColor);
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: itemColor, size: 22),
        title: Text(
          title,
          style: TextStyle(
            color: itemColor,
            fontSize: 14,
            fontWeight: isDestructive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 20),
        onTap: onTap ?? () {},
      ),
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

  void _showDeleteAccountDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.secondaryColor),
            SizedBox(width: 8),
            Text('Delete Account?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete your account? This action is permanent and cannot be undone.\n\n'
          'All your company profile information, enquiry history, and data stored in MuskMover will be immediately erased.',
          style: TextStyle(color: AppTheme.textSecondaryColor, fontSize: 14, height: 1.4),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondaryColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              final success = await authProvider.deleteAccount();
              if (!context.mounted) return;
              if (success) {
                await Provider.of<EnquiryProvider>(context, listen: false).clearEnquiries();
              }
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? 'Your account and data have been deleted.'
                        : (authProvider.errorMessage ?? 'Failed to delete account. Please try again.'),
                  ),
                  backgroundColor: success ? AppTheme.primaryColor : AppTheme.secondaryColor,
                ),
              );
              if (success) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Delete Account', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _launchWebUrl(BuildContext context, String urlString) async {
    final uri = Uri.parse(urlString);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        await launchUrl(uri);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open $urlString: $e'),
            backgroundColor: AppTheme.secondaryColor,
          ),
        );
      }
    }
  }

  Widget _buildAvatarImage(String? imagePath, {double size = 100}) {
    if (imagePath != null && imagePath.trim().isNotEmpty) {
      final trimmed = imagePath.trim();
      if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
        return Image.network(
          trimmed,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Center(
            child: Icon(Icons.business_rounded, size: size * 0.5, color: AppTheme.primaryColor),
          ),
        );
      }
      final file = File(trimmed);
      if (file.existsSync()) {
        return Image.file(
          file,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Center(
            child: Icon(Icons.business_rounded, size: size * 0.5, color: AppTheme.primaryColor),
          ),
        );
      }
    }
    return Center(
      child: Icon(Icons.business_rounded, size: size * 0.5, color: AppTheme.primaryColor),
    );
  }
}
