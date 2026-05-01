import 'package:flutter/material.dart';
import 'package:musk_mover/app_theme.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String selectedFont = 'Serif';
  Color selectedColor = AppTheme.primaryColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('MUSKMOVER', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: AppTheme.primaryColor),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Product Image
            Container(
              height: 350,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: AssetImage('assets/images/logo.png'), // Placeholder
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Thumbnails
            SizedBox(
              height: 60,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildThumbnail(isSelected: true),
                  _buildThumbnail(),
                  _buildThumbnail(),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Product Info
            const Text(
              'ELITE SERIES',
              style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2),
            ),
            const SizedBox(height: 8),
            Text('MV MAMAELIZABET1', style: textTheme.displayLarge?.copyWith(fontSize: 28)),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text(
                  'Price on Request',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'IN STOCK',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textSecondaryColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'A high-performance utility vessel/crew boat optimized for offshore logistics. Featuring our proprietary specification engine for corporate fleet branding.',
              style: TextStyle(color: AppTheme.textSecondaryColor, height: 1.5),
            ),
            
            const SizedBox(height: 32),
            
            // Specification Engine
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.settings_suggest_rounded, color: AppTheme.primaryColor),
                      SizedBox(width: 12),
                      Text('Specification Engine', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryColor)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('FLEET MONOGRAM / ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: AppTheme.textSecondaryColor)),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter company ID...',
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('ENGINE CONFIGURATION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: AppTheme.textSecondaryColor)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildToggleButton('Diesel', isSelected: selectedFont == 'Diesel'),
                      const SizedBox(width: 8),
                      _buildToggleButton('Hybrid', isSelected: selectedFont == 'Hybrid'),
                      const SizedBox(width: 8),
                      _buildToggleButton('Electric', isSelected: selectedFont == 'Electric'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('HULL COATING COLOR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: AppTheme.textSecondaryColor)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildColorOption(AppTheme.primaryColor),
                      _buildColorOption(Colors.white),
                      _buildColorOption(AppTheme.secondaryColor),
                      _buildColorOption(const Color(0xFFFFB800)),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Live Preview
            const Text('LIVE PREVIEW', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textSecondaryColor)),
            const SizedBox(height: 8),
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: AssetImage('assets/images/logo.png'), // Placeholder for preview
                  fit: BoxFit.contain,
                  opacity: 0.5,
                ),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Text(
                      'MUSK LOGISTICS',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: 4),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                      child: const Row(
                        children: [
                          Icon(Icons.visibility_rounded, size: 14, color: Colors.black),
                          SizedBox(width: 4),
                          Text('LIVE PREVIEW', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Feature Cards
            _buildFeatureTile(Icons.water_drop_outlined, 'ABS Certified Hull', 'Certified for all-weather offshore operations.'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildFeatureTile(Icons.speed_rounded, 'Eco-Mode Speed', 'Optimized for fuel efficiency.')),
                const SizedBox(width: 16),
                Expanded(child: _buildFeatureTile(Icons.security_rounded, 'Fleet Tracking', 'Real-time GPS tracking.')),
              ],
            ),
            
            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.favorite_border_rounded, color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.mail_outline_rounded),
                    label: const Text('Make Enquiry', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail({bool isSelected = false}) {
    return Container(
      width: 60,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: isSelected ? Border.all(color: AppTheme.primaryColor, width: 2) : null,
      ),
      child: const Icon(Icons.directions_boat_filled_rounded, color: Color(0xFFCBD5E1), size: 30),
    );
  }

  Widget _buildToggleButton(String label, {bool isSelected = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? AppTheme.primaryColor : const Color(0xFFE2E8F0)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorOption(Color color) {
    bool isSelected = selectedColor == color;
    return GestureDetector(
      onTap: () => setState(() => selectedColor = color),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE2E8F0), width: isSelected ? 3 : 1),
        ),
      ),
    );
  }

  Widget _buildFeatureTile(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 24),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: AppTheme.textSecondaryColor, fontSize: 12)),
        ],
      ),
    );
  }
}
