import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:musk_mover/providers/cart_provider.dart';
import 'package:musk_mover/providers/saved_provider.dart';
import 'package:musk_mover/screens/saved_screen.dart';
import 'package:musk_mover/app_theme.dart';
import 'package:musk_mover/models/product_model.dart';

class ProductDetailScreen extends StatefulWidget {
  final Vessel? vessel;
  final Equipment? equipment;

  const ProductDetailScreen({
    super.key,
    this.vessel,
    this.equipment,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedImageIndex = 0;
  String selectedConfig = 'Diesel';
  Color selectedColor = AppTheme.primaryColor;

  Widget _buildPlaceholder({double height = 350, bool isVessel = true}) {
    return Container(
      height: height,
      width: double.infinity,
      color: const Color(0xFFF1F5F9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isVessel ? Icons.directions_boat_rounded : Icons.precision_manufacturing_rounded,
              size: 56,
              color: const Color(0xFF94A3B8),
            ),
            const SizedBox(height: 8),
            const Text(
              'No Image Available',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final vessel = widget.vessel;
    final equipment = widget.equipment;
    final isVessel = vessel != null;

    final name = vessel?.name ?? equipment?.name ?? 'Item Detail';
    final category = vessel?.type ?? equipment?.category ?? (isVessel ? 'VESSEL' : 'EQUIPMENT');
    final images = vessel?.images.isNotEmpty == true
        ? vessel!.images
        : (equipment?.images.isNotEmpty == true ? equipment!.images : <String>[]);

    final String? currentImageUrl = (images.isNotEmpty && _selectedImageIndex < images.length)
        ? images[_selectedImageIndex]
        : (images.isNotEmpty ? images.first : null);

    final String price = (vessel?.dailyRate != null && vessel!.dailyRate!.isNotEmpty)
        ? '₦${vessel.dailyRate} / day'
        : ((equipment?.dailyRate != null && equipment!.dailyRate!.isNotEmpty)
            ? '₦${equipment.dailyRate} / day'
            : 'Price on Request');

    final String status = vessel?.status ?? equipment?.status ?? 'AVAILABLE';
    final String? condition = vessel?.condition ?? equipment?.condition;
    final String? details = vessel?.details ?? equipment?.details;

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
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: currentImageUrl != null && currentImageUrl.isNotEmpty
                  ? Image.network(
                      currentImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(height: 350, isVessel: isVessel),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                    )
                  : _buildPlaceholder(height: 350, isVessel: isVessel),
            ),
            
            // Image Thumbnails Gallery
            if (images.length > 1) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 64,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedImageIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedImageIndex = index),
                      child: Container(
                        width: 64,
                        height: 64,
                        margin: const EdgeInsets.only(right: 12),
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? AppTheme.primaryColor : const Color(0xFFCBD5E1),
                            width: isSelected ? 2.5 : 1,
                          ),
                        ),
                        child: Image.network(
                          images[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: const Color(0xFFF1F5F9),
                            child: const Icon(Icons.image_outlined, size: 22, color: Color(0xFF94A3B8)),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Product Info
            Text(
              category.toUpperCase(),
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(name, style: textTheme.displayLarge?.copyWith(fontSize: 26)),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  price,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: status.toUpperCase() == 'AVAILABLE'
                        ? const Color(0xFFECFDF5)
                        : const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: status.toUpperCase() == 'AVAILABLE'
                          ? const Color(0xFF10B981).withValues(alpha: 0.3)
                          : const Color(0xFFFFB800).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: status.toUpperCase() == 'AVAILABLE'
                          ? const Color(0xFF059669)
                          : const Color(0xFFD97706),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Details / Description
            if (details != null && details.isNotEmpty) ...[
              Text(
                details,
                style: const TextStyle(color: AppTheme.textSecondaryColor, height: 1.6, fontSize: 14),
              ),
              const SizedBox(height: 12),
            ],
            if (condition != null && condition.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_outlined, size: 18, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Condition: $condition',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.primaryColor),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 32),
            
            // Specification Engine / Customization
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
                  const Text('CONFIGURATION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: AppTheme.textSecondaryColor)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildToggleButton('Diesel', isSelected: selectedConfig == 'Diesel'),
                      const SizedBox(width: 8),
                      _buildToggleButton('Hybrid', isSelected: selectedConfig == 'Hybrid'),
                      const SizedBox(width: 8),
                      _buildToggleButton('Electric', isSelected: selectedConfig == 'Electric'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('COATING COLOR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: AppTheme.textSecondaryColor)),
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
            
            // Feature Cards
            _buildFeatureTile(Icons.water_drop_outlined, 'ABS Certified', 'Certified for all-weather offshore operations.'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildFeatureTile(Icons.speed_rounded, 'Eco-Mode Support', 'Optimized for fuel and power efficiency.')),
                const SizedBox(width: 16),
                Expanded(child: _buildFeatureTile(Icons.security_rounded, 'Fleet Tracking', 'Real-time GPS tracking & logistics.')),
              ],
            ),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
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
              Consumer<SavedProvider>(
                builder: (context, savedProvider, _) {
                  final itemId = vessel?.id ?? equipment?.id ?? '';
                  final isSaved = savedProvider.isSaved(itemId);

                  return InkWell(
                    onTap: () {
                      final nowSaved = savedProvider.toggleSaved(vessel: vessel, equipment: equipment);
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            nowSaved
                                ? 'Moved "$name" to Saved Items!'
                                : 'Removed "$name" from Saved Items',
                          ),
                          backgroundColor: AppTheme.primaryColor,
                          duration: const Duration(seconds: 3),
                          action: nowSaved
                              ? SnackBarAction(
                                  label: 'VIEW SAVED',
                                  textColor: AppTheme.logoOrange,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const SavedScreen(),
                                      ),
                                    );
                                  },
                                )
                              : null,
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        color: isSaved ? const Color(0xFFFEF2F2) : Colors.white,
                        border: Border.all(
                          color: isSaved ? const Color(0xFFEF4444) : const Color(0xFFE2E8F0),
                          width: isSaved ? 1.5 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: isSaved ? const Color(0xFFEF4444) : AppTheme.primaryColor,
                        size: 26,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final cartProvider = Provider.of<CartProvider>(context, listen: false);
                      final itemId = vessel?.id ?? equipment?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
                      cartProvider.addItem(CartItem(
                        id: itemId,
                        name: name,
                        info: condition != null ? 'Condition: $condition' : 'Lease Request',
                        status: status,
                        type: isVessel ? 'vessel' : 'equipment',
                      ));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added "$name" to Enquiry Cart!'),
                          backgroundColor: AppTheme.primaryColor,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
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

  Widget _buildToggleButton(String label, {bool isSelected = false}) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedConfig = label),
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
