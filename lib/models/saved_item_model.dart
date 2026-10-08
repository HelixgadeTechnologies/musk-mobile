import 'package:musk_mover/models/product_model.dart';

class SavedItem {
  final String id;
  final String name;
  final String type; // 'vessel' or 'equipment'
  final Vessel? vessel;
  final Equipment? equipment;
  final DateTime savedAt;

  SavedItem({
    required this.id,
    required this.name,
    required this.type,
    this.vessel,
    this.equipment,
    DateTime? savedAt,
  }) : savedAt = savedAt ?? DateTime.now();

  bool get isVessel => type == 'vessel' || vessel != null;

  String? get status => vessel?.status ?? equipment?.status;
  
  String? get dailyRate => vessel?.dailyRate ?? equipment?.dailyRate;
  
  List<String> get images => vessel?.images ?? equipment?.images ?? [];
  
  String get category => vessel?.type ?? equipment?.category ?? (isVessel ? 'VESSEL' : 'EQUIPMENT');
  
  String? get condition => vessel?.condition ?? equipment?.condition;
  
  String? get year => vessel?.yearBuilt ?? equipment?.yearManufactured;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'vessel': vessel?.toJson(),
      'equipment': equipment?.toJson(),
      'savedAt': savedAt.toIso8601String(),
    };
  }

  factory SavedItem.fromJson(Map<String, dynamic> json) {
    return SavedItem(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      type: (json['type'] ?? 'vessel').toString(),
      vessel: json['vessel'] != null ? Vessel.fromJson(Map<String, dynamic>.from(json['vessel'])) : null,
      equipment: json['equipment'] != null ? Equipment.fromJson(Map<String, dynamic>.from(json['equipment'])) : null,
      savedAt: json['savedAt'] != null ? DateTime.tryParse(json['savedAt'].toString()) ?? DateTime.now() : DateTime.now(),
    );
  }
}
