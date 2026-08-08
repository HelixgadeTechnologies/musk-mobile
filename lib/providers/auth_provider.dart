import 'dart:convert';
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
  static const String _userKey = 'user_data';

  AuthProvider() {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString(_tokenKey);
      final savedUser = prefs.getString(_userKey);
      if (savedToken != null && savedToken.isNotEmpty) {
        _token = savedToken;
        _isLoggedIn = true;
        if (savedUser != null && savedUser.isNotEmpty) {
          try {
            _user = json.decode(savedUser) as Map<String, dynamic>;
          } catch (_) {}
        }
      } else {
        _isLoggedIn = false;
        _token = null;
        _user = null;
      }
    } catch (e) {
      _isLoggedIn = false;
      _token = null;
      _user = null;
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
      final data = response['data'] is Map<String, dynamic> ? response['data'] as Map<String, dynamic> : response;
      _token = data['token'] ?? response['token'];
      _user = data['user'] is Map<String, dynamic> ? data['user'] as Map<String, dynamic> : response['user'];
      _isLoggedIn = true;

      final prefs = await SharedPreferences.getInstance();
      if (_token != null) {
        await prefs.setString(_tokenKey, _token!);
      }
      if (_user != null) {
        await prefs.setString(_userKey, json.encode(_user));
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
      final data = response['data'] is Map<String, dynamic> ? response['data'] as Map<String, dynamic> : response;
      _token = data['token'] ?? response['token'];
      _user = data['user'] is Map<String, dynamic> ? data['user'] as Map<String, dynamic> : response['user'];
      _isLoggedIn = true;

      final prefs = await SharedPreferences.getInstance();
      if (_token != null) {
        await prefs.setString(_tokenKey, _token!);
      }
      if (_user != null) {
        await prefs.setString(_userKey, json.encode(_user));
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
    await prefs.remove(_userKey);
    notifyListeners();
  }
}
