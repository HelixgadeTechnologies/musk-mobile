import 'package:flutter/material.dart';
import 'package:musk_mover/app_theme.dart';
import 'package:musk_mover/screens/splash_screen.dart';
import 'package:musk_mover/screens/marketplace_screen.dart';
import 'package:musk_mover/screens/profile_screen.dart';
import 'package:musk_mover/screens/cart_screen.dart';

void main() {
  runApp(const MuskMoverApp());
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

  final List<Widget> _screens = [
    const HomePage(),
    const MarketplaceScreen(),
    const CartScreen(),
    const Center(child: Text('Saved Items')), // Placeholder
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
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

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
          Stack(
            children: [
              IconButton(icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black), onPressed: () {}),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: Color(0xFFFFB800), shape: BoxShape.circle),
                  constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                  child: const Text('3', style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                ),
              )
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
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
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFB800),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              minimumSize: const Size(0, 40), // Override the global infinity width
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
                  _buildCategoryItem('Vessels', Icons.directions_boat_filled_rounded),
                  _buildCategoryItem('Engines', Icons.settings_input_component_rounded),
                  _buildCategoryItem('Safety', Icons.health_and_safety_rounded),
                  _buildCategoryItem('Navigation', Icons.explore_rounded),
                  _buildCategoryItem('Parts', Icons.build_rounded),
                ],
              ),
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
                        _buildFlashCard('Hydraulic Pump', r'$4,500', r'$3,375', '-25%', 0.7),
                        _buildFlashCard('Main Engine X1', r'$3,200', r'$1,920', '-40%', 0.3),
                        _buildFlashCard('Life Raft', r'$1,200', r'$900', '-25%', 0.9),
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
                      TextButton(onPressed: () {}, child: const Text('VIEW ALL', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.65,
                    children: [
                      _buildRecommendedCard('MV MAMAELIZABET1', 'VESSELS', r'$1.2M'),
                      _buildRecommendedCard('Explorer Utility', 'VESSELS', r'$7,200/d'),
                      _buildRecommendedCard('Marine Engine', 'EQUIPMENT', r'$9,500'),
                      _buildRecommendedCard('Diving Kit Pro', 'SAFETY', r'$3,200'),
                    ],
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
                    onPressed: () {},
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
    );
  }

  Widget _buildCategoryItem(String label, IconData icon) {
    return Padding(
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
    );
  }

  Widget _buildTimerBox(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
      child: Text(value, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildFlashCard(String name, String oldPrice, String newPrice, String discount, double stock) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(height: 100, decoration: const BoxDecoration(color: Color(0xFFF1F5F9), borderRadius: BorderRadius.vertical(top: Radius.circular(12)))),
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
                Text(oldPrice, style: const TextStyle(color: Color(0xFF94A3B8), decoration: TextDecoration.lineThrough, fontSize: 10)),
                Text(newPrice, style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: stock, backgroundColor: const Color(0xFFF1F5F9), color: const Color(0xFFFFB800), minHeight: 4),
                const SizedBox(height: 4),
                Text('${(stock * 20).toInt()} items left', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 8)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedCard(String name, String category, String price) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF1F5F9))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(height: 140, decoration: const BoxDecoration(color: Color(0xFFF8FAFC), borderRadius: BorderRadius.vertical(top: Radius.circular(12)))),
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
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(price, style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: const Color(0xFFFFB800), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.add_shopping_cart_rounded, size: 16, color: Colors.black),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
