import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:musk_mover/providers/cart_provider.dart';
import 'package:musk_mover/providers/auth_provider.dart';
import 'package:musk_mover/providers/product_provider.dart';
import 'package:musk_mover/screens/marketplace_screen.dart';
import 'package:musk_mover/services/brevo_email_service.dart';
import 'dart:math';
import 'package:musk_mover/app_theme.dart';
import 'package:musk_mover/models/enquiry_model.dart';
import 'package:musk_mover/providers/enquiry_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      if (productProvider.equipment.isEmpty) {
        productProvider.fetchEquipment();
      }
      if (productProvider.vessels.isEmpty) {
        productProvider.fetchVessels();
      }
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      cartProvider.repairItemImages(productProvider.vessels, productProvider.equipment);
    });
  }

  String? resolveCartItemImage(CartItem item, ProductProvider productProvider) {
    final clean = item.primaryImageUrl;
    if (clean != null && clean.isNotEmpty) return clean;

    // Search equipment by ID or exact name
    for (final eq in productProvider.equipment) {
      if ((eq.id.isNotEmpty && eq.id == item.id) ||
          eq.name.trim().toLowerCase() == item.name.trim().toLowerCase()) {
        if (eq.images.isNotEmpty) return eq.images.first;
      }
    }

    // Search vessels by ID or exact name
    for (final vs in productProvider.vessels) {
      if ((vs.id.isNotEmpty && vs.id == item.id) ||
          vs.name.trim().toLowerCase() == item.name.trim().toLowerCase()) {
        if (vs.images.isNotEmpty) return vs.images.first;
      }
    }

    // Fallback: substring match if item name has at least 3 characters
    final itemName = item.name.trim().toLowerCase();
    if (itemName.length >= 3) {
      for (final eq in productProvider.equipment) {
        final eqName = eq.name.trim().toLowerCase();
        if (eqName.contains(itemName) || itemName.contains(eqName)) {
          if (eq.images.isNotEmpty) return eq.images.first;
        }
      }
      for (final vs in productProvider.vessels) {
        final vsName = vs.name.trim().toLowerCase();
        if (vsName.contains(itemName) || itemName.contains(vsName)) {
          if (vs.images.isNotEmpty) return vs.images.first;
        }
      }
    }

    return null;
  }

  Widget _buildItemPlaceholder(String type, {double size = 32}) {
    final isVessel = type.toLowerCase() == 'vessel';
    return Container(
      color: const Color(0xFFF1F5F9),
      child: Center(
        child: Icon(
          isVessel ? Icons.directions_boat_rounded : Icons.precision_manufacturing_rounded,
          color: const Color(0xFF94A3B8),
          size: size,
        ),
      ),
    );
  }

  void _showImagePreview(BuildContext context, String imageUrl, String title) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    constraints: const BoxConstraints(maxHeight: 350),
                    width: double.infinity,
                    color: const Color(0xFF0F172A),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Padding(
                        padding: EdgeInsets.all(40),
                        child: Icon(Icons.broken_image_rounded, size: 60, color: Colors.white54),
                      ),
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40.0),
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                radius: 18,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 18, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCheckoutReviewModal(BuildContext context, CartProvider cartProvider, ProductProvider productProvider) async {
    if (cartProvider.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty. Please add items to proceed.'),
          backgroundColor: AppTheme.secondaryColor,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    final user = authProvider.user;

    // Fetch Company Email (Priority: companyEmail -> contactPersonEmail -> email -> SharedPreferences -> default)
    String initialCompanyEmail = '';
    if (authProvider.companyEmail.isNotEmpty) {
      initialCompanyEmail = authProvider.companyEmail;
    } else if (user?['companyEmail']?.toString().trim().isNotEmpty == true) {
      initialCompanyEmail = user!['companyEmail'].toString().trim();
    } else if (user?['contactPersonEmail']?.toString().trim().isNotEmpty == true) {
      initialCompanyEmail = user!['contactPersonEmail'].toString().trim();
    } else if (user?['email']?.toString().trim().isNotEmpty == true) {
      initialCompanyEmail = user!['email'].toString().trim();
    } else {
      initialCompanyEmail = prefs.getString('saved_company_email') ??
          prefs.getString('saved_login_email') ??
          'info@musklogistics.com';
    }

    // Fetch Company Address for Delivery Base (Priority: companyAddress -> address -> deliveryBase -> officeAddress -> SharedPreferences -> default)
    String initialCompanyAddress = '';
    if (authProvider.companyAddress.isNotEmpty) {
      initialCompanyAddress = authProvider.companyAddress;
    } else if (user?['companyAddress']?.toString().trim().isNotEmpty == true) {
      initialCompanyAddress = user!['companyAddress'].toString().trim();
    } else if (user?['address']?.toString().trim().isNotEmpty == true) {
      initialCompanyAddress = user!['address'].toString().trim();
    } else if (user?['deliveryBase']?.toString().trim().isNotEmpty == true) {
      initialCompanyAddress = user!['deliveryBase'].toString().trim();
    } else if (user?['officeAddress']?.toString().trim().isNotEmpty == true) {
      initialCompanyAddress = user!['officeAddress'].toString().trim();
    } else {
      initialCompanyAddress = prefs.getString('saved_company_address') ??
          prefs.getString('saved_delivery_base') ??
          'Federal Ocean Terminal, Onne Port, Rivers State';
    }

    final emailController = TextEditingController(text: initialCompanyEmail);
    final portController = TextEditingController(text: initialCompanyAddress);
    final noteController = TextEditingController();

    bool isSubmitting = false;

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.88,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Modal Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Review Enquiry Assets',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Verify items and images before checking out',
                              style: TextStyle(fontSize: 12, color: AppTheme.textSecondaryColor),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppTheme.textSecondaryColor),
                          onPressed: () => Navigator.pop(bottomSheetContext),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Content
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        // Assets Banner
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.1)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.verified_outlined, color: AppTheme.primaryColor, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '${cartProvider.itemCount} asset(s) selected for official fleet quote.',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Selected Marine Assets (With Images)',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                        ),
                        const SizedBox(height: 12),
                        // List of items with their images
                        ...cartProvider.items.map((item) {
                          final img = resolveCartItemImage(item, productProvider);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                // Thumbnail with tap to view full preview
                                GestureDetector(
                                  onTap: () {
                                    if (img != null && img.isNotEmpty) {
                                      _showImagePreview(context, img, item.name);
                                    }
                                  },
                                  child: Container(
                                    width: 68,
                                    height: 68,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: const Color(0xFFF1F5F9),
                                      border: Border.all(color: const Color(0xFFCBD5E1)),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        (img != null && img.isNotEmpty)
                                            ? Image.network(
                                                img,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) => _buildItemPlaceholder(item.type, size: 22),
                                                loadingBuilder: (_, child, progress) => progress == null
                                                    ? child
                                                    : const Center(
                                                        child: SizedBox(
                                                          width: 16,
                                                          height: 16,
                                                          child: CircularProgressIndicator(strokeWidth: 2),
                                                        ),
                                                      ),
                                              )
                                            : _buildItemPlaceholder(item.type, size: 22),
                                        Positioned(
                                          bottom: 2,
                                          right: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: const BoxDecoration(
                                              color: Colors.black54,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.zoom_in, color: Colors.white, size: 10),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.info,
                                        style: const TextStyle(fontSize: 11, color: AppTheme.textSecondaryColor),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppTheme.primaryColor.withValues(alpha: 0.08),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              item.type.toUpperCase(),
                                              style: const TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.primaryColor,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Quantity: ${item.quantity}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: AppTheme.logoOrange,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Recipient & Location Details',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.edit_note_rounded, size: 14, color: AppTheme.primaryColor),
                                  SizedBox(width: 4),
                                  Text(
                                    'Editable',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Pre-filled with your company profile details. Tap any field to edit before confirming.',
                          style: TextStyle(fontSize: 12, color: AppTheme.textSecondaryColor),
                        ),
                        const SizedBox(height: 14),
                        // Email input (Pre-filled with company email, fully editable)
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Company / Contact Email',
                            hintText: 'e.g. operations@marine.com',
                            prefixIcon: const Icon(Icons.business_outlined, size: 20),
                            suffixIcon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.textSecondaryColor),
                            helperText: 'Pre-filled company email (tap to edit)',
                            helperStyle: const TextStyle(fontSize: 11, color: AppTheme.textSecondaryColor),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Delivery Base input (Pre-filled with company address, fully editable)
                        TextField(
                          controller: portController,
                          decoration: InputDecoration(
                            labelText: 'Operating Port / Delivery Base',
                            hintText: 'e.g. Onne Port, Lagos Anchorage',
                            prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
                            suffixIcon: const Icon(Icons.edit_location_alt_outlined, size: 18, color: AppTheme.textSecondaryColor),
                            helperText: 'Pre-filled delivery base / company address (tap to edit)',
                            helperStyle: const TextStyle(fontSize: 11, color: AppTheme.textSecondaryColor),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Note input
                        TextField(
                          controller: noteController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            labelText: 'Project Notes (Optional)',
                            hintText: 'Duration, charter terms, or specific requirements...',
                            prefixIcon: const Icon(Icons.notes_rounded, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                  // Bottom Action
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          offset: const Offset(0, -4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  final email = emailController.text.trim();
                                  final portLocation = portController.text.trim();

                                  if (email.isEmpty || !email.contains('@')) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please enter a valid company email address.'),
                                        backgroundColor: AppTheme.secondaryColor,
                                      ),
                                    );
                                    return;
                                  }

                                  setSheetState(() {
                                    isSubmitting = true;
                                  });

                                  // Update & persist company details so future enquiries reuse the edited preference
                                  await authProvider.updateCompanyDetails(
                                    companyEmail: email,
                                    companyAddress: portLocation,
                                  );

                                  // Send email via Brevo
                                  final success = await BrevoEmailService.sendFleetEnquiryEmail(
                                    customerEmail: email,
                                    portLocation: portLocation,
                                    notes: noteController.text.trim(),
                                    items: cartProvider.items,
                                    imageResolver: (item) => resolveCartItemImage(item, productProvider),
                                  );

                                  if (context.mounted) {
                                    if (success) {
                                      // Persist to Enquiry History
                                      try {
                                        final randRef = 1000 + Random().nextInt(9000);
                                        final now = DateTime.now();
                                        final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
                                        final enquiryId = 'ENQ-$dateStr-$randRef';
                                        final enquiryItems = cartProvider.items.map((ci) => EnquiryItem(
                                          id: ci.id,
                                          name: ci.name,
                                          type: ci.type,
                                          quantity: ci.quantity,
                                          imageUrl: resolveCartItemImage(ci, productProvider),
                                        )).toList();

                                        final newEnquiry = Enquiry(
                                          id: enquiryId,
                                          createdAt: now,
                                          customerEmail: email,
                                          portLocation: portLocation,
                                          notes: noteController.text.trim(),
                                          status: 'Submitted',
                                          items: enquiryItems,
                                        );

                                        Provider.of<EnquiryProvider>(context, listen: false).addEnquiry(newEnquiry);
                                      } catch (e) {
                                        debugPrint('Error recording enquiry history: $e');
                                      }

                                      Navigator.pop(bottomSheetContext);
                                      _showEnquirySuccessDialog(context, cartProvider, email, portLocation);
                                    } else {
                                      setSheetState(() {
                                        isSubmitting = false;
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Failed to deliver enquiry email. Please check your connection and try again.'),
                                          backgroundColor: AppTheme.secondaryColor,
                                          duration: Duration(seconds: 4),
                                        ),
                                      );
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: isSubmitting
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    ),
                                    SizedBox(width: 12),
                                    Text('SENDING ENQUIRY...'),
                                  ],
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Confirm & Submit Enquiry', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    SizedBox(width: 10),
                                    Icon(Icons.send_rounded, size: 18),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEnquirySuccessDialog(BuildContext context, CartProvider cartProvider, String email, String deliveryBase) {
    final itemCount = cartProvider.itemCount;
    cartProvider.clearCart();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppTheme.accentColor,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Enquiry Sent Successfully!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'We have received your quotation request for $itemCount marine asset(s).\n\nA customized charter quote and specifications sheet will be sent to:\n$email${deliveryBase.isNotEmpty ? '\n\nDelivery Destination:\n$deliveryBase' : ''}',
                  style: const TextStyle(fontSize: 13, color: AppTheme.textSecondaryColor, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.primaryColor),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text('Cart', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: AppTheme.primaryColor),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer2<CartProvider, ProductProvider>(
        builder: (context, cartProvider, productProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Selection Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My Selection (${cartProvider.itemCount})',
                      style: textTheme.displayMedium?.copyWith(fontSize: 22),
                    ),
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
                if (cartProvider.items.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.05),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.shopping_cart_outlined, color: AppTheme.primaryColor, size: 30),
                        ),
                        const SizedBox(height: 16),
                        const Text('Your cart is empty', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        const Text(
                          'Explore our fleet of offshore vessels and heavy equipment to add to your enquiry.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppTheme.textSecondaryColor, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cartProvider.items.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final item = cartProvider.items[index];
                      return _buildCartItem(context, cartProvider, productProvider, item);
                    },
                  ),

                const SizedBox(height: 24),

                // Add Another Item Box
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MarketplaceScreen()),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.15), style: BorderStyle.solid),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.add_circle_outline_rounded, color: AppTheme.primaryColor, size: 32),
                        SizedBox(height: 12),
                        Text('Add another item?', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                        SizedBox(height: 4),
                        Text(
                          'Browse our latest marine collection.',
                          style: TextStyle(color: AppTheme.textSecondaryColor, fontSize: 12),
                        ),
                      ],
                    ),
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
                      Text('Enquiry Summary', style: textTheme.displayMedium?.copyWith(fontSize: 20)),
                      const SizedBox(height: 12),
                      const Text(
                        'Your selection of marine assets will be sent to our fleet management team for a detailed quote.',
                        style: TextStyle(color: AppTheme.textSecondaryColor, height: 1.5),
                      ),
                      const SizedBox(height: 20),

                      // Assets in Enquiry visual preview
                      if (cartProvider.items.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Assets in this Enquiry',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryColor),
                            ),
                            Text(
                              '${cartProvider.items.length} asset${cartProvider.items.length > 1 ? "s" : ""}',
                              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondaryColor, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 116,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: cartProvider.items.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, idx) {
                              final item = cartProvider.items[idx];
                              final img = resolveCartItemImage(item, productProvider);
                              return GestureDetector(
                                onTap: () {
                                  if (img != null && img.isNotEmpty) {
                                    _showImagePreview(context, img, item.name);
                                  }
                                },
                                child: Container(
                                  width: 110,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Stack(
                                        children: [
                                          Container(
                                            height: 68,
                                            width: 110,
                                            decoration: const BoxDecoration(
                                              borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
                                              color: Color(0xFFF1F5F9),
                                            ),
                                            clipBehavior: Clip.antiAlias,
                                            child: (img != null && img.isNotEmpty)
                                                ? Image.network(
                                                    img,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (_, __, ___) => _buildItemPlaceholder(item.type, size: 24),
                                                    loadingBuilder: (_, child, progress) => progress == null
                                                        ? child
                                                        : const Center(
                                                            child: SizedBox(
                                                              width: 16,
                                                              height: 16,
                                                              child: CircularProgressIndicator(strokeWidth: 2),
                                                            ),
                                                          ),
                                                  )
                                                : _buildItemPlaceholder(item.type, size: 24),
                                          ),
                                          Positioned(
                                            top: 4,
                                            right: 4,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppTheme.primaryColor.withValues(alpha: 0.85),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                'x${item.quantity}',
                                                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 4,
                                            left: 4,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: item.type == 'vessel'
                                                    ? AppTheme.primaryColor.withValues(alpha: 0.8)
                                                    : AppTheme.logoOrange.withValues(alpha: 0.9),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                item.type.toUpperCase(),
                                                style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                        child: Text(
                                          item.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(
                            '${cartProvider.itemCount} Asset(s)',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

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
                            Icon(Icons.mark_email_read_outlined, color: AppTheme.primaryColor, size: 16),
                            SizedBox(width: 8),
                            Text(
                              'FLEET ENQUIRY SYSTEM',
                              style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Proceed Button (Check out action)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: cartProvider.items.isEmpty
                              ? null
                              : () => _showCheckoutReviewModal(context, cartProvider, productProvider),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(0xFFE2E8F0),
                            disabledForegroundColor: const Color(0xFF94A3B8),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Review & Send Enquiry', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              SizedBox(width: 12),
                              Icon(Icons.send_rounded, size: 20),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Center(
                        child: Text(
                          'A response will be sent to your registered company email within 24 hours.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartProvider cartProvider, ProductProvider productProvider, CartItem item) {
    final img = resolveCartItemImage(item, productProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item Image Container with tap to enlarge
              GestureDetector(
                onTap: () {
                  if (img != null && img.isNotEmpty) {
                    _showImagePreview(context, img, item.name);
                  }
                },
                child: Container(
                  width: 84,
                  height: 84,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      (img != null && img.isNotEmpty)
                          ? Image.network(
                              img,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => _buildItemPlaceholder(item.type),
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryColor),
                                  ),
                                );
                              },
                            )
                          : _buildItemPlaceholder(item.type),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.zoom_in, color: Colors.white, size: 10),
                        ),
                      ),
                    ],
                  ),
                ),
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
                            item.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => cartProvider.removeItem(item.id),
                          child: const Icon(Icons.delete_outline_rounded, color: AppTheme.secondaryColor, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.type.toUpperCase(),
                            style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.info,
                            style: const TextStyle(color: AppTheme.textSecondaryColor, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: item.status.toUpperCase() == 'AVAILABLE'
                                ? const Color(0xFF10B981)
                                : AppTheme.logoOrange,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item.status,
                          style: const TextStyle(color: AppTheme.textSecondaryColor, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
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
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => cartProvider.updateQuantity(item.id, item.quantity - 1),
                      child: const Icon(Icons.remove, size: 16, color: AppTheme.primaryColor),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                    ),
                    GestureDetector(
                      onTap: () => cartProvider.updateQuantity(item.id, item.quantity + 1),
                      child: const Icon(Icons.add, size: 16, color: AppTheme.primaryColor),
                    ),
                  ],
                ),
              ),
              const Text(
                'Quote Pending',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
