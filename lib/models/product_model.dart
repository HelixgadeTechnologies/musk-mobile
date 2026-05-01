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
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      status: json['status'],
      condition: json['condition'],
      dailyRate: json['dailyRate'],
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      yearBuilt: json['yearBuilt'],
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
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      status: json['status'],
      condition: json['condition'],
      dailyRate: json['dailyRate'],
      images: json['images'] != null ? List<String>.from(json['images']) : [],
    );
  }
}
