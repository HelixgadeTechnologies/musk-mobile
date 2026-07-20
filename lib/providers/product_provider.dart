import 'package:flutter/material.dart';
import 'package:musk_mover/models/product_model.dart';
import 'package:musk_mover/services/api_service.dart';

class ProductProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Vessel> _vessels = [];
  List<Equipment> _equipment = [];
  
  bool _isLoadingVessels = false;
  bool _isLoadingEquipment = false;

  String? _vesselsError;
  String? _equipmentError;

  List<Vessel> get vessels => _vessels;
  List<Equipment> get equipment => _equipment;
  
  bool get isLoadingVessels => _isLoadingVessels;
  bool get isLoadingEquipment => _isLoadingEquipment;

  String? get vesselsError => _vesselsError;
  String? get equipmentError => _equipmentError;

  Future<void> fetchVessels() async {
    if (_vessels.isNotEmpty) return; // Cache

    _isLoadingVessels = true;
    _vesselsError = null;
    // We want the UI to see the loading state immediately if it's the first time
    notifyListeners();

    try {
      _vessels = await _apiService.fetchVessels();
    } catch (e) {
      _vesselsError = e.toString();
    } finally {
      _isLoadingVessels = false;
      notifyListeners();
    }
  }

  Future<void> fetchEquipment() async {
    if (_equipment.isNotEmpty) return; // Cache

    _isLoadingEquipment = true;
    _equipmentError = null;
    notifyListeners();

    try {
      _equipment = await _apiService.fetchEquipment();
    } catch (e) {
      _equipmentError = e.toString();
    } finally {
      _isLoadingEquipment = false;
      notifyListeners();
    }
  }
}
