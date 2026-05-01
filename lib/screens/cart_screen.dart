import 'package:flutter/material.dart';
import 'package:musk_mover/app_theme.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD), // Very light grey/white background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.primaryColor),
          onPressed: () {},
        ),
        title: const Text('Cart', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
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
            // Selection Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('My Selection (2)', style: textTheme.displayMedium?.copyWith(fontSize: 22)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'REVIEW ITEMS',
                    style: TextStyle(color: AppTheme.primaryColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Cart Items
            _buildCartItem(
              context,
              name: 'MV MAMAELIZABET1',
              info: 'Lease Duration: 6 Months',
              status: 'Excellent Condition',
              price: r'$1,250,000',
            ),
            const SizedBox(height: 16),
            _buildCartItem(
              context,
              name: 'Hydraulic Pump System',
              info: 'Model: HP-X900',
              status: 'In Stock',
              price: r'$4,200',
            ),
            
            const SizedBox(height: 24),
            
            // Add Another Item Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2), style: BorderStyle.solid), // Note: Flutter doesn't natively do dashed easily without a package, but we'll use a light border
              ),
              child: Column(
                children: [
                  const Icon(Icons.add_circle_outline_rounded, color: AppTheme.primaryColor, size: 32),
                  const SizedBox(height: 12),
                  const Text('Add another item?', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                  const SizedBox(height: 4),
                  const Text(
                    'Browse our latest marine collection.',
                    style: TextStyle(color: AppTheme.textSecondaryColor, fontSize: 12),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Order Summary
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF1F5F9)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order Summary', style: textTheme.displayMedium?.copyWith(fontSize: 20)),
                  const SizedBox(height: 24),
                  _buildSummaryRow('Subtotal', r'$1,254,200'),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Delivery Fee', r'$500.00'),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Tax (Calculated)', r'$125,470.00'),
                  const Divider(height: 40, thickness: 1, color: Color(0xFFF1F5F9)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Text(
                        r'$1,380,170.00',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: AppTheme.primaryColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Checkout Protection Badge
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.verified_user_outlined, color: AppTheme.primaryColor, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'SECURE CHECKOUT GUARANTEED',
                          style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Proceed Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Proceed to Payment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          SizedBox(width: 12),
                          Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Payment Icons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPaymentIcon('VISA'),
                      const SizedBox(width: 8),
                      _buildPaymentIcon('MC'),
                      const SizedBox(width: 8),
                      _buildPaymentIcon('APPLE'),
                      const SizedBox(width: 8),
                      _buildPaymentIcon('PAYPAL'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, {required String name, required String info, required String status, required String price}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.directions_boat_filled_rounded, color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.delete_outline_rounded, color: AppTheme.secondaryColor, size: 20),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.edit_outlined, size: 12, color: AppTheme.textSecondaryColor),
                        const SizedBox(width: 4),
                        Text(info, style: const TextStyle(color: AppTheme.textSecondaryColor, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(status, style: const TextStyle(color: AppTheme.textSecondaryColor, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.remove, size: 16, color: AppTheme.primaryColor),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('1', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                    ),
                    Icon(Icons.add, size: 16, color: AppTheme.primaryColor),
                  ],
                ),
              ),
              Text(
                price,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondaryColor, fontSize: 14)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  Widget _buildPaymentIcon(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)),
      ),
    );
  }
}
