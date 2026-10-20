import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:musk_mover/app_theme.dart';
import 'package:musk_mover/providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _contactNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _contactPhoneController;
  late final TextEditingController _companyNameController;
  late final TextEditingController _industrySectorController;
  late final TextEditingController _companyEmailController;
  late final TextEditingController _companyPhoneController;
  late final TextEditingController _companyAddressController;

  String? _selectedImagePath;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    _contactNameController = TextEditingController(
      text: user?['contactPersonName'] ?? user?['contactName'] ?? '',
    );
    _emailController = TextEditingController(
      text: user?['contactPersonEmail'] ?? user?['email'] ?? '',
    );
    _contactPhoneController = TextEditingController(
      text: user?['contactPersonPhone'] ?? user?['contactPhone'] ?? '',
    );
    _companyNameController = TextEditingController(
      text: user?['companyLegalName'] ?? user?['companyName'] ?? '',
    );
    _industrySectorController = TextEditingController(
      text: user?['industrySector'] ?? '',
    );
    _companyEmailController = TextEditingController(
      text: user?['companyEmail'] ?? '',
    );
    _companyPhoneController = TextEditingController(
      text: user?['companyPhone'] ?? '',
    );
    _companyAddressController = TextEditingController(
      text: user?['companyAddress'] ??
          user?['address'] ??
          user?['deliveryBase'] ??
          '',
    );

    _selectedImagePath = authProvider.profileImage;
  }

  @override
  void dispose() {
    _contactNameController.dispose();
    _emailController.dispose();
    _contactPhoneController.dispose();
    _companyNameController.dispose();
    _industrySectorController.dispose();
    _companyEmailController.dispose();
    _companyPhoneController.dispose();
    _companyAddressController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final hasExisting = _selectedImagePath != null && _selectedImagePath!.isNotEmpty;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (pickerContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  'Profile Photo',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined, color: AppTheme.primaryColor),
                  title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.w500)),
                  onTap: () async {
                    Navigator.pop(pickerContext);
                    try {
                      final XFile? file = await picker.pickImage(
                        source: ImageSource.gallery,
                        maxWidth: 1024,
                        maxHeight: 1024,
                        imageQuality: 85,
                      );
                      if (file != null) {
                        setState(() {
                          _selectedImagePath = file.path;
                        });
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Could not access gallery: $e'),
                            backgroundColor: AppTheme.secondaryColor,
                          ),
                        );
                      }
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined, color: AppTheme.primaryColor),
                  title: const Text('Take Photo with Camera', style: TextStyle(fontWeight: FontWeight.w500)),
                  onTap: () async {
                    Navigator.pop(pickerContext);
                    try {
                      final XFile? file = await picker.pickImage(
                        source: ImageSource.camera,
                        maxWidth: 1024,
                        maxHeight: 1024,
                        imageQuality: 85,
                      );
                      if (file != null) {
                        setState(() {
                          _selectedImagePath = file.path;
                        });
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Could not access camera: $e'),
                            backgroundColor: AppTheme.secondaryColor,
                          ),
                        );
                      }
                    }
                  },
                ),
                if (hasExisting)
                  ListTile(
                    leading: const Icon(Icons.delete_outline_rounded, color: AppTheme.secondaryColor),
                    title: const Text('Remove Photo', style: TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.w500)),
                    onTap: () {
                      Navigator.pop(pickerContext);
                      setState(() {
                        _selectedImagePath = '';
                      });
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
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

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.updateProfileDetails(
        contactPersonName: _contactNameController.text,
        contactPersonEmail: _emailController.text,
        contactPersonPhone: _contactPhoneController.text,
        companyLegalName: _companyNameController.text,
        industrySector: _industrySectorController.text,
        companyEmail: _companyEmailController.text,
        companyPhone: _companyPhoneController.text,
        companyAddress: _companyAddressController.text,
        profileImage: _selectedImagePath,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile details updated successfully!'),
            backgroundColor: AppTheme.primaryColor,
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: AppTheme.secondaryColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

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
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _isSaving ? null : _saveProfile,
              child: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryColor),
                    )
                  : const Text(
                      'Save',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Upload Section
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
                            border: Border.all(
                              color: AppTheme.primaryColor.withValues(alpha: 0.2),
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: _buildAvatarImage(_selectedImagePath, size: 100),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: _pickProfileImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppTheme.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _pickProfileImage,
                      icon: const Icon(Icons.add_a_photo_outlined, size: 16, color: AppTheme.primaryColor),
                      label: Text(
                        _selectedImagePath != null && _selectedImagePath!.isNotEmpty
                            ? 'Change Profile Photo'
                            : 'Upload Profile Photo',
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Section 1: Contact Person
              const Text(
                'CONTACT PERSON',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _contactNameController,
                label: 'Contact Person Name',
                icon: Icons.person_outline_rounded,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter contact name' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _emailController,
                label: 'Work Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) => (v == null || !v.contains('@')) ? 'Please enter a valid work email' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _contactPhoneController,
                label: 'Contact Phone',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 28),

              // Section 2: Company Information
              const Text(
                'COMPANY INFORMATION',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _companyNameController,
                label: 'Company Legal Name',
                icon: Icons.business_rounded,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter company name' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _industrySectorController,
                label: 'Industry Sector',
                icon: Icons.domain_rounded,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _companyEmailController,
                label: 'Company Email',
                icon: Icons.alternate_email_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: (v) => (v == null || !v.contains('@')) ? 'Please enter a valid company email' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _companyPhoneController,
                label: 'Company Phone',
                icon: Icons.phone_in_talk_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _companyAddressController,
                label: 'Delivery Base / Address',
                icon: Icons.location_on_outlined,
                maxLines: 2,
              ),

              const SizedBox(height: 32),

              // Primary Save Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            ),
                            SizedBox(width: 12),
                            Text('Saving Changes...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        )
                      : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: AppTheme.primaryColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.textSecondaryColor, fontSize: 13),
        prefixIcon: Icon(icon, color: AppTheme.primaryColor, size: 20),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
        ),
      ),
    );
  }
}
