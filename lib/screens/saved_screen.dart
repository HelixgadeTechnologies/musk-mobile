import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:musk_mover/app_theme.dart';
import 'package:musk_mover/models/saved_item_model.dart';
import 'package:musk_mover/providers/cart_provider.dart';
import 'package:musk_mover/providers/saved_provider.dart';
import 'package:musk_mover/screens/product_detail_screen.dart';

class SavedScreen extends StatefulWidget {
  final VoidCallback? onExplore;

  const SavedScreen({super.key, this.onExplore});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  String _selectedFilter = 'ALL'; // 'ALL', 'VESSELS', 'EQUIPMENT'

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.primaryColor),
                onPressed: () => Navigator.of(context).pop(),
              )
            : const Padding(
                padding: EdgeInsets.all(12.0),
                child: Icon(Icons.favorite_rounded, color: AppTheme.primaryColor),
              ),
        title: const Text(
          'Saved Items',
          style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          Consumer<SavedProvider>(
            builder: (context, savedProvider, _) {
              if (savedProvider.itemCount == 0) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.delete_sweep_outlined, color: Color(0xFF64748B)),
                tooltip: 'Clear all',
                onPressed: () => _confirmClearAll(context, savedProvider),
              );
            },
          ),
        ],
      ),
      body: Consumer<SavedProvider>(
        builder: (context, savedProvider, _) {
          final items = savedProvider.items;

          if (items.isEmpty) {
            return _buildEmptyState(context);
          }

          final filteredItems = items.where((item) {
            if (_selectedFilter == 'VESSELS') return item.isVessel;
            if (_selectedFilter == 'EQUIPMENT') return !item.isVessel;
            return true;
          }).toList();

          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
              // Header Summary & Filter Chips
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'My Bookmarks (${items.length})',
                            style: textTheme.displayMedium?.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.bookmark_rounded, size: 12, color: AppTheme.primaryColor),
                                const SizedBox(width: 4),
                                Text(
                                  '${items.length} ${items.length == 1 ? 'ITEM' : 'ITEMS'}',
                                  style: const TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Filter chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('ALL', 'All Items', items.length),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              'VESSELS',
                              'Vessels',
                              items.where((i) => i.isVessel).length,
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              'EQUIPMENT',
                              'Equipment',
                              items.where((i) => !i.isVessel).length,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (filteredItems.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(
                        'No items in "$_selectedFilter" category.',
                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = filteredItems[index];
                        return _buildSavedCard(context, item, savedProvider);
                      },
                      childCount: filteredItems.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String filterKey, String label, int count) {
    final isSelected = _selectedFilter == filterKey;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = filterKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : const Color(0xFFE2E8F0),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF475569),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.25) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedCard(BuildContext context, SavedItem item, SavedProvider savedProvider) {
    final images = item.images;
    final imageUrl = images.isNotEmpty ? images.first : null;
    final status = (item.status ?? 'AVAILABLE').toUpperCase();
    final isAvailable = status == 'AVAILABLE';
    final price = (item.dailyRate != null && item.dailyRate!.isNotEmpty)
        ? '₦${item.dailyRate} / day'
        : 'Price on Request';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(
                vessel: item.vessel,
                equipment: item.equipment,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section: Image + Badges + Delete button
            Stack(
              children: [
                SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: (imageUrl != null && imageUrl.isNotEmpty)
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholderCard(item.isVessel),
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              color: const Color(0xFFF1F5F9),
                              child: const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            );
                          },
                        )
                      : _buildPlaceholderCard(item.isVessel),
                ),
                // Status Badge
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isAvailable ? const Color(0xFF10B981) : AppTheme.logoOrange,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: isAvailable ? Colors.white : Colors.black,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                // Category Tag
                Positioned(
                  top: 10,
                  left: isAvailable ? 90 : 100,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.category.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                // Remove Bookmark Button
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    elevation: 2,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {
                        savedProvider.removeSaved(item.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Removed "${item.name}" from saved items'),
                            duration: const Duration(seconds: 2),
                            action: SnackBarAction(
                              label: 'UNDO',
                              textColor: AppTheme.logoOrange,
                              onPressed: () {
                                savedProvider.saveItem(
                                  vessel: item.vessel,
                                  equipment: item.equipment,
                                );
                              },
                            ),
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(7.0),
                        child: Icon(
                          Icons.favorite_rounded,
                          color: Color(0xFFEF4444), // Red favorite icon
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Bottom Section: Details & Quick Actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.year != null && item.year!.isNotEmpty
                                  ? 'Built/Mfg ${item.year}'
                                  : (item.condition != null
                                      ? 'Condition: ${item.condition}'
                                      : (item.isVessel ? 'Commercial Marine Asset' : 'Heavy Marine Equipment')),
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        price,
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // View details button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailScreen(
                                  vessel: item.vessel,
                                  equipment: item.equipment,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.visibility_outlined, size: 16),
                          label: const Text('View Details', style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryColor,
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Add to Enquiry Cart button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final cartProvider = Provider.of<CartProvider>(context, listen: false);
                            cartProvider.addItem(CartItem(
                              id: item.id,
                              name: item.name,
                              info: item.condition != null ? 'Condition: ${item.condition}' : 'Lease Request',
                              status: item.status ?? 'AVAILABLE',
                              type: item.type,
                            ));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Added "${item.name}" to Enquiry Cart!'),
                                backgroundColor: AppTheme.primaryColor,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_shopping_cart_rounded, size: 16),
                          label: const Text('Enquire', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
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

  Widget _buildPlaceholderCard(bool isVessel) {
    return Container(
      color: const Color(0xFFF1F5F9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isVessel ? Icons.directions_boat_rounded : Icons.precision_manufacturing_rounded,
              size: 40,
              color: const Color(0xFF94A3B8),
            ),
            const SizedBox(height: 6),
            const Text(
              'MuskMover Fleet',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.favorite_border_rounded,
                  size: 48,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Saved Items Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Browse our marine fleet and equipment.\nTap the heart icon on any asset to save it here for fast access and enquiries.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () {
                if (widget.onExplore != null) {
                  widget.onExplore!();
                } else if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
              icon: const Icon(Icons.explore_rounded),
              label: const Text('EXPLORE FLEET', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.logoOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClearAll(BuildContext context, SavedProvider savedProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Saved Items?'),
        content: const Text('This will remove all items from your saved list.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              savedProvider.clearAll();
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('CLEAR ALL'),
          ),
        ],
      ),
    );
  }
}
