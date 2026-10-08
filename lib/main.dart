import 'package:flutter/material.dart';
import 'package:musk_mover/app_theme.dart';
import 'package:musk_mover/screens/splash_screen.dart';
import 'package:musk_mover/screens/marketplace_screen.dart';
import 'package:musk_mover/screens/profile_screen.dart';
import 'package:musk_mover/screens/cart_screen.dart';
import 'package:musk_mover/screens/saved_screen.dart';
import 'package:musk_mover/screens/product_detail_screen.dart';
import 'package:musk_mover/models/product_model.dart';
import 'package:provider/provider.dart';
import 'package:musk_mover/providers/auth_provider.dart';
import 'package:musk_mover/providers/cart_provider.dart';
import 'package:musk_mover/providers/saved_provider.dart';
import 'package:musk_mover/providers/product_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => SavedProvider()),
      ],
      child: const MuskMoverApp(),
    ),
  );
}

class MuskMoverApp extends StatelessWidget {
  const MuskMoverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MuskMover - Marine Marketplace',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      RepaintBoundary(
        child: HomePage(
          key: const PageStorageKey('home'),
          onNavigateToCategories: () {
            setState(() {
              _currentIndex = 1;
            });
          },
        ),
      ),
      const RepaintBoundary(child: MarketplaceScreen(key: PageStorageKey('marketplace'))),
      const RepaintBoundary(child: CartScreen(key: PageStorageKey('cart'))),
      RepaintBoundary(
        child: SavedScreen(
          key: const PageStorageKey('saved'),
          onExplore: () {
            setState(() {
              _currentIndex = 1;
            });
          },
        ),
      ),
      const RepaintBoundary(child: ProfileScreen(key: PageStorageKey('profile'))),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: const Color(0xFF94A3B8),
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_filled), label: 'HOME'),
          const BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'CATEGORIES'),
          const BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), activeIcon: Icon(Icons.shopping_cart_rounded), label: 'CART'),
          BottomNavigationBarItem(
            icon: Consumer<SavedProvider>(
              builder: (context, saved, _) {
                if (saved.itemCount == 0) {
                  return const Icon(Icons.favorite_border_rounded);
                }
                return Badge(
                  label: Text('${saved.itemCount}'),
                  backgroundColor: AppTheme.secondaryColor,
                  child: const Icon(Icons.favorite_border_rounded),
                );
              },
            ),
            activeIcon: Consumer<SavedProvider>(
              builder: (context, saved, _) {
                if (saved.itemCount == 0) {
                  return const Icon(Icons.favorite_rounded);
                }
                return Badge(
                  label: Text('${saved.itemCount}'),
                  backgroundColor: AppTheme.secondaryColor,
                  child: const Icon(Icons.favorite_rounded),
                );
              },
            ),
            label: 'SAVED',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), activeIcon: Icon(Icons.person_rounded), label: 'ACCOUNT'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppTheme.logoOrange,
        child: const Icon(Icons.support_agent_rounded, color: Colors.white),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final VoidCallback? onNavigateToCategories;
  const HomePage({super.key, this.onNavigateToCategories});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchVessels();
      context.read<ProductProvider>().fetchEquipment();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.menu_rounded, color: Colors.black), onPressed: () {}),
        title: const Text('MUSKMOVER', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.tune_rounded, color: Colors.black), onPressed: () {}),
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
                    onPressed: () {},
                  ),
                  if (cartProvider.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: AppTheme.logoOrange, shape: BoxShape.circle),
                        constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                        child: Text(
                          '${cartProvider.itemCount}',
                          style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryColor,
        onRefresh: () async {
          await Future.wait([
            context.read<ProductProvider>().fetchVessels(forceRefresh: true),
            context.read<ProductProvider>().fetchEquipment(forceRefresh: true),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search 'Vessels'...",
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),

              // Hero Banner
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                constraints: const BoxConstraints(minHeight: 180),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryColor, Color(0xFF1E293B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('LIMITED EDITION', style: TextStyle(color: AppTheme.logoOrange, fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 8),
                    const Text('Premium Fleet\nOffshore Deals', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 160,
                      child: ElevatedButton(
                        onPressed: widget.onNavigateToCategories,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.logoOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          minimumSize: const Size(0, 40),
                        ),
                        child: const Text('EXPLORE FLEET', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),

              // Categories
              SizedBox(
                height: 110,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildCategoryItem(context, 'Vessels', Icons.directions_boat_filled_rounded, onTap: widget.onNavigateToCategories),
                    _buildCategoryItem(context, 'Engines', Icons.settings_input_component_rounded, onTap: widget.onNavigateToCategories),
                    _buildCategoryItem(context, 'Safety', Icons.health_and_safety_rounded, onTap: widget.onNavigateToCategories),
                    _buildCategoryItem(context, 'Navigation', Icons.explore_rounded, onTap: widget.onNavigateToCategories),
                    _buildCategoryItem(context, 'Parts', Icons.build_rounded, onTap: widget.onNavigateToCategories),
                  ],
                ),
              ),

              // Available Vessels (Live backend data)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'OFFSHORE FLEET',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Available Vessels',
                            style: textTheme.displayMedium?.copyWith(fontSize: 18),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: widget.onNavigateToCategories,
                      child: const Row(
                        children: [
                          Text('VIEW ALL', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded, size: 14, color: AppTheme.primaryColor),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Consumer<ProductProvider>(
                builder: (context, productProvider, child) {
                  if (productProvider.isLoadingVessels && productProvider.vessels.isEmpty) {
                    return const SizedBox(
                      height: 240,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.primaryColor),
                            SizedBox(height: 12),
                            Text('Fetching vessels from backend...', style: TextStyle(color: AppTheme.textSecondaryColor, fontSize: 12)),
                          ],
                        ),
                      ),
                    );
                  } else if (productProvider.vesselsError != null && productProvider.vessels.isEmpty) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFCA5A5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626)),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Unable to load vessels from backend',
                              style: TextStyle(color: Color(0xFF991B1B), fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ),
                          TextButton(
                            onPressed: () => productProvider.fetchVessels(forceRefresh: true),
                            child: const Text('Retry', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
                          ),
                        ],
                      ),
                    );
                  } else if (productProvider.vessels.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text('No vessels available currently.', style: TextStyle(color: AppTheme.textSecondaryColor)),
                      ),
                    );
                  }

                  return SizedBox(
                    height: 260,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: productProvider.vessels.length,
                      itemBuilder: (context, index) {
                        final vessel = productProvider.vessels[index];
                        return _buildVesselCard(context, vessel);
                      },
                    ),
                  );
                },
              ),

              // Flash Sales
              Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                padding: const EdgeInsets.symmetric(vertical: 20),
                color: AppTheme.primaryColor,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Icon(Icons.flash_on_rounded, color: Colors.white, size: 20),
                          const SizedBox(width: 6),
                          const Expanded(
                            child: Text(
                              'FLASH DEALS',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('ENDS IN: ', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
                                _buildTimerBox('04'),
                                const Text(' : ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                _buildTimerBox('12'),
                                const Text(' : ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                _buildTimerBox('59'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Consumer<ProductProvider>(
                      builder: (context, productProvider, child) {
                        final equipmentList = productProvider.equipment;
                        if (equipmentList.isEmpty) {
                          if (productProvider.isLoadingEquipment) {
                            return const SizedBox(
                              height: 220,
                              child: Center(
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              ),
                            );
                          }
                          return const SizedBox(
                            height: 60,
                            child: Center(
                              child: Text('Check back soon for flash deals.', style: TextStyle(color: Colors.white70)),
                            ),
                          );
                        }

                        return SizedBox(
                          height: 230,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: equipmentList.length > 8 ? 8 : equipmentList.length,
                            itemBuilder: (context, index) {
                              final equip = equipmentList[index];
                              return _buildFlashCard(context, equip);
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Recommended
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Recommended for You',
                            style: textTheme.displayMedium?.copyWith(fontSize: 18),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        TextButton(
                          onPressed: widget.onNavigateToCategories,
                          child: const Text('VIEW ALL', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Consumer<ProductProvider>(
                      builder: (context, productProvider, child) {
                        final vessels = productProvider.vessels;
                        final equipment = productProvider.equipment;

                        if (vessels.isEmpty && equipment.isEmpty) {
                          if (productProvider.isLoadingVessels || productProvider.isLoadingEquipment) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 32),
                              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            );
                          }
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Text('No recommendations available currently.', style: TextStyle(color: AppTheme.textSecondaryColor)),
                            ),
                          );
                        }

                        final List<dynamic> recommendedItems = [];
                        recommendedItems.addAll(vessels.take(2));
                        recommendedItems.addAll(equipment.take(4 - recommendedItems.length));
                        if (recommendedItems.isEmpty && vessels.isNotEmpty) {
                          recommendedItems.addAll(vessels.take(4));
                        }

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.63,
                          ),
                          itemCount: recommendedItems.length,
                          itemBuilder: (context, index) {
                            final item = recommendedItems[index];
                            return _buildDynamicRecommendedCard(
                              context,
                              vessel: item is Vessel ? item : null,
                              equipment: item is Equipment ? item : null,
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Promo Card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.1)),
                ),
                child: Column(
                  children: [
                    const Text('Customize Your Fleet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryColor)),
                    const SizedBox(height: 8),
                    const Text(
                      'Choose specifications, engine capacity, and deck layouts for your custom vessel.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textSecondaryColor),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: widget.onNavigateToCategories,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      child: const Text('START CUSTOMIZING'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVesselCard(BuildContext context, Vessel vessel) {
    final imageUrl = vessel.images.isNotEmpty ? vessel.images.first : null;
    final status = vessel.status ?? 'AVAILABLE';
    final rate = vessel.dailyRate != null && vessel.dailyRate!.isNotEmpty
        ? '₦${vessel.dailyRate} / day'
        : 'Contact for Price';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProductDetailScreen(vessel: vessel)),
        );
      },
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 16, top: 4, bottom: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 115,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          width: double.infinity,
                          height: 115,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildPlaceholderCard(isVessel: true),
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
                      : _buildPlaceholderCard(isVessel: true),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: status.toUpperCase() == 'AVAILABLE'
                          ? const Color(0xFF10B981)
                          : AppTheme.logoOrange,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (vessel.yearBuilt != null && vessel.yearBuilt!.isNotEmpty)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Built ${vessel.yearBuilt}',
                        style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vessel.type.isNotEmpty ? vessel.type.toUpperCase() : 'VESSELS',
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vessel.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          rate,
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.logoOrange,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicRecommendedCard(
    BuildContext context, {
    Vessel? vessel,
    Equipment? equipment,
  }) {
    final isVessel = vessel != null;
    final name = vessel?.name ?? equipment?.name ?? '';
    final category = vessel?.type ?? equipment?.category ?? (isVessel ? 'VESSELS' : 'EQUIPMENT');
    final images = vessel?.images ?? equipment?.images ?? [];
    final imageUrl = images.isNotEmpty ? images.first : null;
    final status = vessel?.status ?? equipment?.status ?? 'AVAILABLE';
    final rate = (vessel?.dailyRate != null && vessel!.dailyRate!.isNotEmpty)
        ? '₦${vessel.dailyRate} / day'
        : ((equipment?.dailyRate != null && equipment!.dailyRate!.isNotEmpty)
            ? '₦${equipment.dailyRate} / day'
            : 'Contact for Price');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(vessel: vessel, equipment: equipment),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
                    child: Container(
                      color: const Color(0xFFF8FAFC),
                      child: imageUrl != null && imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => _buildPlaceholderCard(isVessel: isVessel),
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)));
                              },
                            )
                          : _buildPlaceholderCard(isVessel: isVessel),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: status.toUpperCase() == 'AVAILABLE'
                            ? const Color(0xFF10B981)
                            : AppTheme.logoOrange,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Consumer<SavedProvider>(
                    builder: (context, savedProvider, _) {
                      final itemId = vessel?.id ?? equipment?.id ?? '';
                      final isSaved = savedProvider.isSaved(itemId);
                      return Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            savedProvider.toggleSaved(vessel: vessel, equipment: equipment);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.85),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              size: 16,
                              color: isSaved ? const Color(0xFFEF4444) : const Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    category.toUpperCase(),
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          rate,
                          style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: AppTheme.logoOrange, borderRadius: BorderRadius.circular(6)),
                        child: const Icon(Icons.mail_outline_rounded, size: 14, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, String label, IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), shape: BoxShape.circle, border: Border.all(color: const Color(0xFFE2E8F0))),
              child: Icon(icon, color: AppTheme.primaryColor, size: 28),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondaryColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerBox(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
      child: Text(value, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildFlashCard(BuildContext context, Equipment equipment) {
    final imageUrl = equipment.images.isNotEmpty ? equipment.images.first : null;
    final rate = (equipment.dailyRate != null && equipment.dailyRate!.isNotEmpty)
        ? '₦${equipment.dailyRate} / day'
        : 'Contact for Price';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProductDetailScreen(equipment: equipment)),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 95,
                  width: double.infinity,
                  color: const Color(0xFFF1F5F9),
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildPlaceholderCard(isVessel: false),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)));
                          },
                        )
                      : _buildPlaceholderCard(isVessel: false),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppTheme.logoOrange, borderRadius: BorderRadius.circular(4)),
                    child: const Text('PROMO', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(equipment.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(rate, style: const TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.w600, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  const LinearProgressIndicator(value: 0.7, backgroundColor: Color(0xFFF1F5F9), color: AppTheme.logoOrange, minHeight: 4),
                  const SizedBox(height: 4),
                  Text(equipment.status ?? 'Available', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 8), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderCard({required bool isVessel}) {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: Center(
        child: Icon(
          isVessel ? Icons.directions_boat_rounded : Icons.precision_manufacturing_rounded,
          color: const Color(0xFFCBD5E1),
          size: 32,
        ),
      ),
    );
  }
}
