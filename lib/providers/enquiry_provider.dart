import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:musk_mover/models/enquiry_model.dart';

class EnquiryProvider extends ChangeNotifier {
  static const String _storageKey = 'user_enquiry_history';

  List<Enquiry> _enquiries = [];
  bool _isLoading = false;

  List<Enquiry> get enquiries => List.unmodifiable(_enquiries);
  bool get isLoading => _isLoading;
  int get totalCount => _enquiries.length;

  EnquiryProvider() {
    loadEnquiries();
  }

  /// Loads saved enquiries from persistent storage
  Future<void> loadEnquiries() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_storageKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decoded = json.decode(jsonString);
        _enquiries = decoded
            .map((item) => Enquiry.fromJson(item as Map<String, dynamic>))
            .toList();
        // Sort descending by creation date (newest first)
        _enquiries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
    } catch (e) {
      debugPrint('Error loading enquiry history: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adds a new enquiry, persists to storage, and notifies listeners
  Future<void> addEnquiry(Enquiry enquiry) async {
    _enquiries.insert(0, enquiry);
    notifyListeners();
    await _saveToPrefs();
  }

  /// Clears all enquiries (e.g. upon account deletion)
  Future<void> clearEnquiries() async {
    _enquiries = [];
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (e) {
      debugPrint('Error clearing enquiry history: $e');
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _enquiries.map((e) => e.toJson()).toList();
      await prefs.setString(_storageKey, json.encode(list));
    } catch (e) {
      debugPrint('Error saving enquiries: $e');
    }
  }
}
