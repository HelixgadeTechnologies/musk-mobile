import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartItem {
  final String id;
  final String name;
  final String info;
  final String status;
  final String type; // 'vessel' or 'equipment'
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.info,
    required this.status,
    required this.type,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'info': info,
      'status': status,
      'type': type,
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      name: json['name'],
      info: json['info'],
      status: json['status'],
      type: json['type'],
      quantity: json['quantity'] ?? 1,
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
  }

  Future<void> _saveCartData() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(_items.map((e) => e.toJson()).toList());
    await prefs.setString('cart_items', encodedData);
  }

  void addItem(CartItem newItem) {
    final existingItemIndex = _items.indexWhere((item) => item.id == newItem.id);
    if (existingItemIndex >= 0) {
      _items[existingItemIndex].quantity += 1;
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
}
