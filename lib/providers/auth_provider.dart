import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:musk_mover/services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _token;
  Map<String, dynamic>? _user;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get token => _token;
  Map<String, dynamic>? get user => _user;

  static const String _tokenKey = 'auth_token';

  AuthProvider() {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString(_tokenKey);
      if (savedToken != null && savedToken.isNotEmpty) {
        _token = savedToken;
        _isLoggedIn = true;
      } else {
        _isLoggedIn = false;
        _token = null;
      }
    } catch (e) {
      _isLoggedIn = false;
      _token = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.loginUser(email, password);
      _token = response['token'] ?? response['data']?['token'] ?? 'mock_token';
      _user = response['user'] ?? response['data']?['user'] ?? response['data'];
      _isLoggedIn = true;

      if (_token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, _token!);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(Map<String, dynamic> userData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.registerUser(userData);
      _token = response['token'] ?? response['data']?['token'] ?? 'mock_token';
      _user = response['user'] ?? response['data']?['user'] ?? response['data'];
      _isLoggedIn = true;

      if (_token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, _token!);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    notifyListeners();
  }
}
