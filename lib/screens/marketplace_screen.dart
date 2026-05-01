import 'package:flutter/material.dart';
import 'package:musk_mover/app_theme.dart';
import 'package:musk_mover/models/product_model.dart';
import 'package:musk_mover/screens/product_detail_screen.dart';
import 'package:musk_mover/services/api_service.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final ApiService _apiService = ApiService();
  
  final List<Map<String, dynamic>> categories = [
    {'name': 'VESSELS', 'icon': Icons.directions_boat_filled_rounded},
    {'name': 'EQUIPMENT', 'icon': Icons.engineering_rounded},
    {'name': 'TECH', 'icon': Icons.terminal_rounded},
    {'name': 'OFFSHORE', 'icon': Icons.oil_barrel_rounded},
    {'name': 'SAFETY', 'icon': Icons.security_rounded},
    {'name': 'LOGISTICS', 'icon': Icons.local_shipping_rounded},
  ];

  int selectedCategoryIndex = 0;

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
    
    if (categoryName == 'VESSELS') {
      return FutureBuilder<List<Vessel>>(
        future: _apiService.fetchVessels(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No vessels available.'));
          } else {
            return _buildProductList(snapshot.data!, isVessel: true);
          }
        },
      );
    } else if (categoryName == 'EQUIPMENT') {
      return FutureBuilder<List<Equipment>>(
        future: _apiService.fetchEquipment(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No equipment available.'));
          } else {
            return _buildProductList(snapshot.data!, isVessel: false);
          }
        },
      );
    } else {
      return Center(child: Text('No data for $categoryName yet.'));
    }
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('EXPLORE COLLECTIONS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryColor, letterSpacing: 1.2)),
                  const SizedBox(height: 4),
                  Text('${categories[selectedCategoryIndex]['name']} FLEET', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
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
              childAspectRatio: 0.8,
              mainAxisSpacing: 20,
              crossAxisSpacing: 16,
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

  Widget _buildCategoryItem(BuildContext context, String title, String? badge, {required bool isVessel, String? imageUrl}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductDetailScreen()));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  if (imageUrl != null && imageUrl.isNotEmpty)
                    Positioned.fill(
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Image.asset(
                          isVessel ? 'assets/images/vessel_1.png' : 'assets/images/engine_1.png',
                          fit: BoxFit.cover,
                        ),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 2,
                            ),
                          );
                        },
                      ),
                    )
                  else
                    Image.asset(
                      isVessel ? 'assets/images/vessel_1.png' : 'assets/images/engine_1.png',
                      fit: BoxFit.cover,
                    ),
                  if (badge != null && badge.isNotEmpty)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: badge.toUpperCase() == 'NEW' ? const Color(0xFFFFB800) : AppTheme.secondaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: badge.toUpperCase() == 'NEW' ? Colors.black : Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
