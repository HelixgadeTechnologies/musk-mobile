import 'package:flutter/material.dart';
import 'package:musk_mover/app_theme.dart';
import 'package:musk_mover/screens/splash_screen.dart';
import 'package:musk_mover/screens/marketplace_screen.dart';
import 'package:musk_mover/screens/profile_screen.dart';
import 'package:musk_mover/screens/cart_screen.dart';
import 'package:musk_mover/screens/product_detail_screen.dart';
import 'package:musk_mover/models/product_model.dart';
import 'package:provider/provider.dart';
import 'package:musk_mover/providers/auth_provider.dart';
import 'package:musk_mover/providers/cart_provider.dart';
import 'package:musk_mover/providers/product_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
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
      const RepaintBoundary(child: Center(child: Text('Saved Items'))),
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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_filled), label: 'HOME'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'CATEGORIES'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), activeIcon: Icon(Icons.shopping_cart_rounded), label: 'CART'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border_rounded), activeIcon: Icon(Icons.favorite_rounded), label: 'SAVED'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), activeIcon: Icon(Icons.person_rounded), label: 'ACCOUNT'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFFFFB800), // Yellow as per UI
        child: const Icon(Icons.support_agent_rounded, color: Colors.black),
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
                        decoration: const BoxDecoration(color: Color(0xFFFFB800), shape: BoxShape.circle),
                        constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                        child: Text(
                          '${cartProvider.itemCount}',
                          style: const TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold),
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
          await context.read<ProductProvider>().fetchVessels(forceRefresh: true);
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
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryColor, Color(0xFF1E293B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 24,
                      top: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('LIMITED EDITION', style: TextStyle(color: Color(0xFFFFB800), fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 8),
                          const Text('Premium Fleet\nOffshore Deals', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: 160,
                            child: ElevatedButton(
                              onPressed: widget.onNavigateToCategories,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFB800),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                minimumSize: const Size(0, 40),
                              ),
                              child: const Text('EXPLORE FLEET', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Categories
              SizedBox(
                height: 100,
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
                    Column(
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
                        Text('Available Vessels', style: textTheme.displayMedium?.copyWith(fontSize: 18)),
                      ],
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
                    height: 250,
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
                          const Icon(Icons.flash_on_rounded, color: Colors.white),
                          const SizedBox(width: 8),
                          const Text('FLASH DEALS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                          const Spacer(),
                          const Text('ENDS IN:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          const SizedBox(width: 8),
                          _buildTimerBox('04'),
                          const Text(' : ', style: TextStyle(color: Colors.white)),
                          _buildTimerBox('12'),
                          const Text(' : ', style: TextStyle(color: Colors.white)),
                          _buildTimerBox('59'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 220,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          _buildFlashCard(context, 'Hydraulic Pump', '-25%', 0.7, 'assets/images/engine_1.png'),
                          _buildFlashCard(context, 'Main Engine X1', '-40%', 0.3, 'assets/images/engine_1.png'),
                          _buildFlashCard(context, 'Life Raft', '-25%', 0.9, 'assets/images/safety_1.png'),
                        ],
                      ),
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
                        Text('Recommended for You', style: textTheme.displayMedium?.copyWith(fontSize: 18)),
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
                        if (vessels.isNotEmpty) {
                          return GridView.builder(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.65,
                            itemCount: vessels.length > 4 ? 4 : vessels.length,
                            itemBuilder: (context, index) {
                              final vessel = vessels[index];
                              return _buildDynamicRecommendedCard(context, vessel);
                            },
                          );
                        }

                        return GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.65,
                          children: [
                            _buildRecommendedCard(context, 'MV MAMAELIZABET1', 'VESSELS', 'assets/images/vessel_1.png'),
                            _buildRecommendedCard(context, 'Explorer Utility', 'VESSELS', 'assets/images/vessel_1.png'),
                            _buildRecommendedCard(context, 'Marine Engine', 'EQUIPMENT', 'assets/images/engine_1.png'),
                            _buildRecommendedCard(context, 'Diving Kit Pro', 'SAFETY', 'assets/images/safety_1.png'),
                          ],
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
                  height: 120,
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
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Image.asset(
                            'assets/images/vessel_1.png',
                            width: double.infinity,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
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
                      : Image.asset(
                          'assets/images/vessel_1.png',
                          width: double.infinity,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: status.toUpperCase() == 'AVAILABLE'
                          ? const Color(0xFF10B981)
                          : const Color(0xFFFFB800),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: status.toUpperCase() == 'AVAILABLE' ? Colors.white : Colors.black,
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
                          color: const Color(0xFFFFB800),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.black),
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

  Widget _buildDynamicRecommendedCard(BuildContext context, Vessel vessel) {
    final imageUrl = vessel.images.isNotEmpty ? vessel.images.first : null;
    final rate = vessel.dailyRate != null && vessel.dailyRate!.isNotEmpty
        ? '₦${vessel.dailyRate}'
        : 'Inquire';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProductDetailScreen(vessel: vessel)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Image.asset(
                            'assets/images/vessel_1.png',
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.asset(
                          'assets/images/vessel_1.png',
                          fit: BoxFit.cover,
                        ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      vessel.status?.toUpperCase() ?? 'VESSEL',
                      style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                const Positioned(top: 8, right: 8, child: Icon(Icons.favorite_border_rounded, size: 20, color: Color(0xFFCBD5E1))),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vessel.type.isNotEmpty ? vessel.type.toUpperCase() : 'VESSELS',
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vessel.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
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
                        decoration: BoxDecoration(color: const Color(0xFFFFB800), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.mail_outline_rounded, size: 16, color: Colors.black),
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

  Widget _buildFlashCard(BuildContext context, String name, String discount, double stock, String imagePath) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductDetailScreen()));
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFFFB800), borderRadius: BorderRadius.circular(4)),
                    child: Text(discount, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  const Text('Contact for Price', style: TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.w500, fontSize: 11)),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: stock, backgroundColor: const Color(0xFFF1F5F9), color: const Color(0xFFFFB800), minHeight: 4),
                  const SizedBox(height: 4),
                  Text('${(stock * 20).toInt()} items left', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 8)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedCard(BuildContext context, String name, String category, String imagePath) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductDetailScreen()));
      },
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF1F5F9))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
                  ),
                ),
                const Positioned(top: 8, right: 8, child: Icon(Icons.favorite_border_rounded, size: 20, color: Color(0xFFCBD5E1))),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Inquire', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: const Color(0xFFFFB800), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.mail_outline_rounded, size: 16, color: Colors.black),
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
}
