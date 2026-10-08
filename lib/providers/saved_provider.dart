import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:musk_mover/models/product_model.dart';
import 'package:musk_mover/models/saved_item_model.dart';

class SavedProvider extends ChangeNotifier {
  List<SavedItem> _items = [];
  bool _isInitialized = false;

  List<SavedItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;
  bool get isInitialized => _isInitialized;

  SavedProvider() {
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? savedData = prefs.getString('saved_items');
      if (savedData != null && savedData.isNotEmpty) {
        final List<dynamic> decodedData = jsonDecode(savedData);
        _items = decodedData
            .map((item) => SavedItem.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading saved items: $e');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> _saveSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encodedData = jsonEncode(_items.map((e) => e.toJson()).toList());
      await prefs.setString('saved_items', encodedData);
    } catch (e) {
      debugPrint('Error writing saved items: $e');
    }
  }

  bool isSaved(String? id) {
    if (id == null || id.isEmpty) return false;
    return _items.any((item) => item.id == id);
  }

  /// Toggles saved state. Returns true if now saved, false if removed.
  bool toggleSaved({Vessel? vessel, Equipment? equipment}) {
    final String? id = vessel?.id ?? equipment?.id;
    if (id == null || id.isEmpty) return false;

    final existingIndex = _items.indexWhere((item) => item.id == id);
    if (existingIndex >= 0) {
      _items.removeAt(existingIndex);
      _saveSavedData();
      notifyListeners();
      return false;
    } else {
      final String name = vessel?.name ?? equipment?.name ?? 'Item';
      final String type = vessel != null ? 'vessel' : 'equipment';
      final newItem = SavedItem(
        id: id,
        name: name,
        type: type,
        vessel: vessel,
        equipment: equipment,
      );
      _items.insert(0, newItem); // newest first
      _saveSavedData();
      notifyListeners();
      return true;
    }
  }

  void saveItem({Vessel? vessel, Equipment? equipment}) {
    final String? id = vessel?.id ?? equipment?.id;
    if (id == null || id.isEmpty) return;

    if (!isSaved(id)) {
      final String name = vessel?.name ?? equipment?.name ?? 'Item';
      final String type = vessel != null ? 'vessel' : 'equipment';
      _items.insert(
        0,
        SavedItem(
          id: id,
          name: name,
          type: type,
          vessel: vessel,
          equipment: equipment,
        ),
      );
      _saveSavedData();
      notifyListeners();
    }
  }

  void removeSaved(String id) {
    final initialLength = _items.length;
    _items.removeWhere((item) => item.id == id);
    if (_items.length != initialLength) {
      _saveSavedData();
      notifyListeners();
    }
  }

  void clearAll() {
    _items.clear();
    _saveSavedData();
    notifyListeners();
  }
}
