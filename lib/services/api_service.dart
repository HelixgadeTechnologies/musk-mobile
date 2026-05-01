import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:musk_mover/models/product_model.dart';

class ApiService {
  static const String baseUrl = 'https://musk-backend.onrender.com/api';

  Future<List<Vessel>> fetchVessels() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/vessels'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
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
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Equipment.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load equipment');
      }
    } catch (e) {
      throw Exception('Error fetching equipment: $e');
    }
  }
}
