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

  String get companyEmail {
    if (_user != null) {
      final email = _user!['companyEmail'] ?? _user!['contactPersonEmail'] ?? _user!['email'];
      if (email != null && email.toString().trim().isNotEmpty) {
        return email.toString().trim();
      }
    }
    return '';
  }

  String get companyAddress {
    if (_user != null) {
      final addr = _user!['companyAddress'] ??
          _user!['address'] ??
          _user!['deliveryBase'] ??
          _user!['officeAddress'] ??
          _user!['location'];
      if (addr != null && addr.toString().trim().isNotEmpty) {
        return addr.toString().trim();
      }
    }
    return '';
  }

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _rememberMeKey = 'remember_me_enabled';
  static const String _sessionExpiryKey = 'session_expiry_timestamp';
  static const String _savedEmailKey = 'saved_login_email';
  static const String _savedPasswordKey = 'saved_login_password';

  AuthProvider() {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final isRemembered = prefs.getBool(_rememberMeKey) ?? false;
      final expiryTimestamp = prefs.getInt(_sessionExpiryKey);

      // If a 30-day window was configured, verify it hasn't expired
      if (isRemembered && expiryTimestamp != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now > expiryTimestamp) {
          // 30 days have elapsed: clear saved credentials & invalidate session
          await clearSavedCredentials();
          await logout();
          return;
        }
      } else if (!isRemembered) {
        // If the user did not opt in to be remembered, don't restore session on fresh startup
        _isLoggedIn = false;
        _token = null;
        _user = null;
        _isLoading = false;
        notifyListeners();
        return;
      }

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

  /// Clear 30-day saved credentials and expiry timestamp
  Future<void> clearSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_rememberMeKey);
      await prefs.remove(_sessionExpiryKey);
      await prefs.remove(_savedEmailKey);
      await prefs.remove(_savedPasswordKey);
    } catch (_) {}
  }

  /// Retrieve saved credentials if within the 30-day validity window
  Future<Map<String, String?>> getSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isRemembered = prefs.getBool(_rememberMeKey) ?? false;
      final expiryTimestamp = prefs.getInt(_sessionExpiryKey);

      if (isRemembered && expiryTimestamp != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now <= expiryTimestamp) {
          return {
            'email': prefs.getString(_savedEmailKey),
            'password': prefs.getString(_savedPasswordKey),
            'rememberMe': 'true',
          };
        } else {
          // 30 days expired, clean up stored credentials
          await clearSavedCredentials();
        }
      }
    } catch (_) {}
    return {
      'email': null,
      'password': null,
      'rememberMe': 'false',
    };
  }

  Future<bool> login(
    String email,
    String password, {
    bool rememberMe = true,
  }) async {
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

      await prefs.setBool(_rememberMeKey, rememberMe);
      if (rememberMe) {
        // Calculate 30-day expiration from right now
        final thirtyDaysExpiry = DateTime.now().add(const Duration(days: 30)).millisecondsSinceEpoch;
        await prefs.setInt(_sessionExpiryKey, thirtyDaysExpiry);
        await prefs.setString(_savedEmailKey, email);
        await prefs.setString(_savedPasswordKey, password);
      } else {
        await prefs.remove(_sessionExpiryKey);
        await prefs.remove(_savedEmailKey);
        await prefs.remove(_savedPasswordKey);
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

      await prefs.setBool(_rememberMeKey, true);
      final thirtyDaysExpiry = DateTime.now().add(const Duration(days: 30)).millisecondsSinceEpoch;
      await prefs.setInt(_sessionExpiryKey, thirtyDaysExpiry);
      if (userData['email'] != null && (userData['email'] as String).isNotEmpty) {
        await prefs.setString(_savedEmailKey, userData['email']);
      }
      if (userData['password'] != null && (userData['password'] as String).isNotEmpty) {
        await prefs.setString(_savedPasswordKey, userData['password']);
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

  /// Updates company contact and location details in memory and SharedPreferences
  Future<void> updateCompanyDetails({String? companyEmail, String? companyAddress}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_user != null) {
        final updatedUser = Map<String, dynamic>.from(_user!);
        if (companyEmail != null && companyEmail.isNotEmpty) {
          updatedUser['companyEmail'] = companyEmail;
        }
        if (companyAddress != null && companyAddress.isNotEmpty) {
          updatedUser['companyAddress'] = companyAddress;
          updatedUser['deliveryBase'] = companyAddress;
        }
        _user = updatedUser;
        await prefs.setString(_userKey, json.encode(_user));
      }
      if (companyEmail != null && companyEmail.isNotEmpty) {
        await prefs.setString('saved_company_email', companyEmail);
      }
      if (companyAddress != null && companyAddress.isNotEmpty) {
        await prefs.setString('saved_company_address', companyAddress);
        await prefs.setString('saved_delivery_base', companyAddress);
      }
      notifyListeners();
    } catch (_) {}
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

  Future<bool> deleteAccount() async {
    _isLoading = true;
    notifyListeners();
    try {
      // Clear all stored local preferences and session data
      await clearSavedCredentials();
      await logout();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
