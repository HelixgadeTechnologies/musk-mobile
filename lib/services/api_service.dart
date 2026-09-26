import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:musk_mover/models/product_model.dart';

class ApiService {
  static const String baseUrl = 'https://api.muskmover.ng/api';

  Future<List<Vessel>> fetchVessels() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/vessels'));
      List<dynamic> data = [];
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        data = responseData['data'] ?? [];
      } else {
        throw Exception('Failed to load vessels');
      }

      // If vessels endpoint is empty, check equipment endpoint for items categorized as vessels
      if (data.isEmpty) {
        final equipResponse = await http.get(Uri.parse('$baseUrl/equipment'));
        if (equipResponse.statusCode == 200) {
          final Map<String, dynamic> equipData = json.decode(equipResponse.body);
          final List<dynamic> equipList = equipData['data'] ?? [];
          data = equipList.where((item) {
            final category = item['category']?.toString().toLowerCase();
            return category == 'vessels' || category == 'vessel';
          }).toList();
        }
      }

      return data.map((json) => Vessel.fromJson(json)).toList();
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
        throw Exception(responseData['message'] ?? responseData['error'] ?? 'Failed to login');
      }
    } catch (e) {
      if (e is Exception) rethrow;
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
        throw Exception(responseData['message'] ?? responseData['error'] ?? 'Failed to register');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Registration error: $e');
    }
  }
}
