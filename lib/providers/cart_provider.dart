import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:musk_mover/models/product_model.dart';
import 'package:musk_mover/services/api_service.dart';

class CartItem {
  final String id;
  final String name;
  final String info;
  final String status;
  final String type; // 'vessel' or 'equipment'
  final String? imageUrl;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.info,
    required this.status,
    required this.type,
    this.imageUrl,
    this.quantity = 1,
  });

  String? get primaryImageUrl {
    if (imageUrl == null || imageUrl!.trim().isEmpty || imageUrl == 'null') return null;
    String clean = imageUrl!.trim();
    while ((clean.startsWith('[') && clean.endsWith(']')) ||
           (clean.startsWith('"') && clean.endsWith('"')) ||
           (clean.startsWith("'") && clean.endsWith("'"))) {
      clean = clean.substring(1, clean.length - 1).trim();
    }
    if (clean.contains(',')) {
      final parts = clean.split(',');
      for (final part in parts) {
        String p = part.trim().replaceAll('"', '').replaceAll("'", '');
        if (p.startsWith('http://') || p.startsWith('https://')) return p;
      }
    }
    clean = clean.replaceAll('"', '').replaceAll("'", '').trim();
    if (clean.startsWith('http://') || clean.startsWith('https://')) return clean;
    if (clean.startsWith('//')) return 'https:$clean';
    return null;
  }

  CartItem copyWith({
    String? id,
    String? name,
    String? info,
    String? status,
    String? type,
    String? imageUrl,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      info: info ?? this.info,
      status: status ?? this.status,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'info': info,
      'status': status,
      'type': type,
      'imageUrl': imageUrl,
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    String? img = json['imageUrl']?.toString();
    if (img != null && img.contains(',')) {
      final parts = img.split(',');
      for (final part in parts) {
        final trimmed = part.trim();
        if (trimmed.startsWith('http')) {
          img = trimmed;
          break;
        }
      }
    }
    return CartItem(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      info: (json['info'] ?? '').toString(),
      status: (json['status'] ?? 'AVAILABLE').toString(),
      type: (json['type'] ?? 'vessel').toString(),
      imageUrl: img,
      quantity: json['quantity'] is int ? json['quantity'] as int : (int.tryParse(json['quantity']?.toString() ?? '1') ?? 1),
    );
  }
}

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  bool _isInitialized = false;

  List<CartItem> get items => _items;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  bool get isInitialized => _isInitialized;

  CartProvider() {
    _loadCartData();
  }

  Future<void> _loadCartData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cartData = prefs.getString('cart_items');
    if (cartData != null) {
      final List<dynamic> decodedData = jsonDecode(cartData);
      _items = decodedData.map((item) => CartItem.fromJson(item)).toList();
    }
    _isInitialized = true;
    notifyListeners();

    // Auto-repair any items stored from earlier sessions that lack images
    _autoRepairMissingImages();
  }

  Future<void> _autoRepairMissingImages() async {
    final needsRepair = _items.any((item) => item.primaryImageUrl == null);
    if (!needsRepair) return;

    try {
      final api = ApiService();
      final equipment = await api.fetchEquipment();
      final vessels = await api.fetchVessels();
      repairItemImages(vessels, equipment);
    } catch (_) {}
  }

  void repairItemImages(List<Vessel> vessels, List<Equipment> equipment) {
    bool hasChanges = false;
    for (int i = 0; i < _items.length; i++) {
      final item = _items[i];
      if (item.primaryImageUrl == null) {
        // Try equipment match
        for (final eq in equipment) {
          if ((eq.id.isNotEmpty && eq.id == item.id) ||
              eq.name.trim().toLowerCase() == item.name.trim().toLowerCase()) {
            if (eq.images.isNotEmpty) {
              _items[i] = _items[i].copyWith(imageUrl: eq.images.first);
              hasChanges = true;
              break;
            }
          }
        }
        if (_items[i].primaryImageUrl != null) continue;

        // Try vessel match
        for (final vs in vessels) {
          if ((vs.id.isNotEmpty && vs.id == item.id) ||
              vs.name.trim().toLowerCase() == item.name.trim().toLowerCase()) {
            if (vs.images.isNotEmpty) {
              _items[i] = _items[i].copyWith(imageUrl: vs.images.first);
              hasChanges = true;
              break;
            }
          }
        }
        if (_items[i].primaryImageUrl != null) continue;

        // Fallback substring matching
        final itemName = item.name.trim().toLowerCase();
        if (itemName.length >= 3) {
          for (final eq in equipment) {
            final eqName = eq.name.trim().toLowerCase();
            if (eqName.contains(itemName) || itemName.contains(eqName)) {
              if (eq.images.isNotEmpty) {
                _items[i] = _items[i].copyWith(imageUrl: eq.images.first);
                hasChanges = true;
                break;
              }
            }
          }
          if (_items[i].primaryImageUrl != null) continue;

          for (final vs in vessels) {
            final vsName = vs.name.trim().toLowerCase();
            if (vsName.contains(itemName) || itemName.contains(vsName)) {
              if (vs.images.isNotEmpty) {
                _items[i] = _items[i].copyWith(imageUrl: vs.images.first);
                hasChanges = true;
                break;
              }
            }
          }
        }
      }
    }
    if (hasChanges) {
      _saveCartData();
      notifyListeners();
    }
  }

  Future<void> _saveCartData() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(_items.map((e) => e.toJson()).toList());
    await prefs.setString('cart_items', encodedData);
  }

  void addItem(CartItem newItem) {
    final existingItemIndex = _items.indexWhere(
      (item) => item.id == newItem.id || item.name.trim().toLowerCase() == newItem.name.trim().toLowerCase(),
    );
    if (existingItemIndex >= 0) {
      _items[existingItemIndex].quantity += 1;
      if (_items[existingItemIndex].primaryImageUrl == null && newItem.primaryImageUrl != null) {
        _items[existingItemIndex] = _items[existingItemIndex].copyWith(imageUrl: newItem.imageUrl);
      }
    } else {
      _items.add(newItem);
    }
    _saveCartData();
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    _saveCartData();
    notifyListeners();
  }

  void updateQuantity(String id, int quantity) {
    if (quantity <= 0) {
      removeItem(id);
      return;
    }
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      _items[index].quantity = quantity;
      _saveCartData();
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    _saveCartData();
    notifyListeners();
  }
}
