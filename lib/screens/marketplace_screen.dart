import 'package:flutter/material.dart';
import 'package:musk_mover/app_theme.dart';
import 'package:musk_mover/models/product_model.dart';
import 'package:musk_mover/screens/product_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:musk_mover/providers/product_provider.dart';
import 'package:musk_mover/widgets/custom_loading_state.dart';
import 'package:musk_mover/widgets/custom_error_state.dart';

class MarketplaceScreen extends StatefulWidget {
  final int initialCategoryIndex;
  const MarketplaceScreen({super.key, this.initialCategoryIndex = 0});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  late int selectedCategoryIndex;

  @override
  void initState() {
    super.initState();
    selectedCategoryIndex = widget.initialCategoryIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ProductProvider>(context, listen: false);
      provider.fetchVessels();
      provider.fetchEquipment();
    });
  }

  final List<Map<String, dynamic>> categories = [
    {'name': 'VESSELS', 'icon': Icons.directions_boat_filled_rounded},
    {'name': 'EQUIPMENT', 'icon': Icons.engineering_rounded},
    {'name': 'TECH', 'icon': Icons.terminal_rounded},
    {'name': 'OFFSHORE', 'icon': Icons.oil_barrel_rounded},
    {'name': 'SAFETY', 'icon': Icons.security_rounded},
    {'name': 'LOGISTICS', 'icon': Icons.local_shipping_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: AppTheme.primaryColor),
          onPressed: () {},
        ),
        title: const Text('CATEGORIES', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: AppTheme.primaryColor),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search equipment, services...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondaryColor),
                filled: true,
                fillColor: AppTheme.primaryColor.withValues(alpha: 0.03),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          
          Expanded(
            child: Row(
              children: [
                // Left Sidebar
                Container(
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(right: BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.05))),
                  ),
                  child: ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final isSelected = selectedCategoryIndex == index;
                      return GestureDetector(
                        onTap: () => setState(() => selectedCategoryIndex = index),
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.03) : Colors.transparent,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (isSelected)
                                Positioned(
                                  left: 0,
                                  top: 15,
                                  bottom: 15,
                                  child: Container(width: 4, decoration: const BoxDecoration(color: AppTheme.primaryColor, borderRadius: BorderRadius.horizontal(right: Radius.circular(4)))),
                                ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    categories[index]['icon'],
                                    color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
                                    size: 28,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    categories[index]['name'],
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Right Content Area
                Expanded(
                  child: _buildContentArea(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentArea() {
    final categoryName = categories[selectedCategoryIndex]['name'];
    
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        if (categoryName == 'VESSELS') {
          if (productProvider.isLoadingVessels && productProvider.vessels.isEmpty) {
            return const CustomLoadingState(message: 'Loading Fleet...');
          } else if (productProvider.vesselsError != null && productProvider.vessels.isEmpty) {
            return CustomErrorState(
              message: productProvider.vesselsError!,
              onRetry: () => productProvider.fetchVessels(forceRefresh: true),
            );
          } else if (productProvider.vessels.isEmpty) {
            return const Center(child: Text('No vessels available.'));
          } else {
            return _buildProductList(productProvider.vessels, isVessel: true);
          }
        }

        // For other categories, we utilize equipment filtered by category
        if (productProvider.isLoadingEquipment && productProvider.equipment.isEmpty) {
          return const CustomLoadingState(message: 'Loading Equipment...');
        } else if (productProvider.equipmentError != null && productProvider.equipment.isEmpty) {
          return CustomErrorState(
            message: productProvider.equipmentError!,
            onRetry: () => productProvider.fetchEquipment(forceRefresh: true),
          );
        }

        List<Equipment> filteredEquipment = [];
        if (categoryName == 'EQUIPMENT') {
          filteredEquipment = productProvider.equipment;
        } else if (categoryName == 'SAFETY') {
          filteredEquipment = productProvider.equipment
              .where((e) => e.category.toLowerCase().contains('safe'))
              .toList();
        } else if (categoryName == 'TECH') {
          filteredEquipment = productProvider.equipment
              .where((e) =>
                  e.category.toLowerCase().contains('nav') ||
                  e.category.toLowerCase().contains('comm') ||
                  e.category.toLowerCase().contains('tech'))
              .toList();
        } else if (categoryName == 'OFFSHORE') {
          filteredEquipment = productProvider.equipment
              .where((e) =>
                  e.category.toLowerCase().contains('prop') ||
                  e.category.toLowerCase().contains('cargo') ||
                  e.category.toLowerCase().contains('vessel'))
              .toList();
        } else if (categoryName == 'LOGISTICS') {
          filteredEquipment = productProvider.equipment
              .where((e) =>
                  e.category.toLowerCase().contains('cargo') ||
                  e.category.toLowerCase().contains('crane'))
              .toList();
        }

        if (filteredEquipment.isEmpty) {
          // If a specific subcategory is empty, fallback to showing all equipment
          filteredEquipment = productProvider.equipment;
        }

        if (filteredEquipment.isEmpty) {
          return const Center(child: Text('No items available currently.'));
        }

        return _buildProductList(filteredEquipment, isVessel: false);
      },
    );
  }

  Widget _buildProductList(List<dynamic> items, {required bool isVessel}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('EXPLORE COLLECTIONS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryColor, letterSpacing: 1.2)),
                    const SizedBox(height: 4),
                    Text(
                      '${categories[selectedCategoryIndex]['name']} FLEET',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Row(
                  children: [
                    Text('View All', style: TextStyle(fontSize: 12, color: AppTheme.textSecondaryColor)),
                    Icon(Icons.chevron_right_rounded, size: 16, color: AppTheme.textSecondaryColor),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.70,
              mainAxisSpacing: 16,
              crossAxisSpacing: 14,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final title = isVessel ? (item as Vessel).name : (item as Equipment).name;
              final badge = isVessel ? (item as Vessel).status : (item as Equipment).status;
              final images = isVessel ? (item as Vessel).images : (item as Equipment).images;
              final imageUrl = images.isNotEmpty ? images.first : null;
              
              return _buildCategoryItem(
                context,
                item,
                title,
                badge,
                imageUrl: imageUrl,
                isVessel: isVessel,
              );
            },
          ),
          
          const SizedBox(height: 32),
          
          _buildPromoBanner(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Build Your Fleet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          const Text('Start with a base specification and customize.', style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFB800),
              foregroundColor: Colors.black,
              minimumSize: const Size(0, 40),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('CUSTOMIZE NOW', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    dynamic item,
    String title,
    String? badge, {
    required bool isVessel,
    String? imageUrl,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              vessel: isVessel ? (item as Vessel) : null,
              equipment: !isVessel ? (item as Equipment) : null,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: (imageUrl != null && imageUrl.isNotEmpty)
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(isVessel: isVessel),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              );
                            },
                          )
                        : _buildPlaceholder(isVessel: isVessel),
                  ),
                  if (badge != null && badge.isNotEmpty)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: badge.toUpperCase() == 'AVAILABLE'
                              ? const Color(0xFF10B981)
                              : const Color(0xFFFFB800),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badge.toUpperCase(),
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: badge.toUpperCase() == 'AVAILABLE' ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Contact for Rates',
                    style: TextStyle(color: AppTheme.primaryColor, fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder({required bool isVessel}) {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: Center(
        child: Icon(
          isVessel ? Icons.directions_boat_rounded : Icons.precision_manufacturing_rounded,
          color: const Color(0xFFCBD5E1),
          size: 36,
        ),
      ),
    );
  }
}
