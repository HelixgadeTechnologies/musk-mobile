class Vessel {
  final String id;
  final String name;
  final String type;
  final String? status;
  final String? condition;
  final String? dailyRate;
  final List<String> images;
  final String? yearBuilt;

  Vessel({
    required this.id,
    required this.name,
    required this.type,
    this.status,
    this.condition,
    this.dailyRate,
    required this.images,
    this.yearBuilt,
  });

  factory Vessel.fromJson(Map<String, dynamic> json) {
    return Vessel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      status: json['status']?.toString(),
      condition: json['condition']?.toString(),
      dailyRate: json['dailyRate']?.toString(),
      images: json['images'] is List 
          ? List<String>.from(json['images']) 
          : (json['images'] is String ? [json['images'] as String] : []),
      yearBuilt: json['yearBuilt']?.toString(),
    );
  }
}

class Equipment {
  final String id;
  final String name;
  final String category;
  final String? status;
  final String? condition;
  final String? dailyRate;
  final List<String> images;

  Equipment({
    required this.id,
    required this.name,
    required this.category,
    this.status,
    this.condition,
    this.dailyRate,
    required this.images,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      status: json['status']?.toString(),
      condition: json['condition']?.toString(),
      dailyRate: json['dailyRate']?.toString(),
      images: json['images'] is List 
          ? List<String>.from(json['images']) 
          : (json['images'] is String ? [json['images'] as String] : []),
    );
  }
}
