import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:musk_mover/models/product_model.dart';

class ApiService {
  static const String baseUrl = 'https://musk-backend.onrender.com/api';

  Future<List<Vessel>> fetchVessels() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/vessels'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'] ?? [];
        return data.map((json) => Vessel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load vessels');
      }
    } catch (e) {
      throw Exception('Error fetching vessels: $e');
    }
  }

  Future<List<Equipment>> fetchEquipment() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/equipment'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'] ?? [];
        return data.map((json) => Equipment.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load equipment');
      }
    } catch (e) {
      throw Exception('Error fetching equipment: $e');
    }
  }

  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to login');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  Future<Map<String, dynamic>> registerUser(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to register');
      }
    } catch (e) {
      throw Exception('Registration error: $e');
    }
  }
}
