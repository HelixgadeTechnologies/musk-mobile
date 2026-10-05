import 'dart:convert';

class Vessel {
  final String id;
  final String name;
  final String type;
  final String? status;
  final String? condition;
  final String? dailyRate;
  final List<String> images;
  final String? yearBuilt;
  final String? details;

  Vessel({
    required this.id,
    required this.name,
    required this.type,
    this.status,
    this.condition,
    this.dailyRate,
    required this.images,
    this.yearBuilt,
    this.details,
  });

  factory Vessel.fromJson(Map<String, dynamic> json) {
    return Vessel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      type: (json['type'] ?? json['category'] ?? 'VESSEL').toString(),
      status: json['status']?.toString(),
      condition: json['condition']?.toString(),
      dailyRate: json['dailyRate']?.toString(),
      images: parseImageList(json['images'] ?? json['image']),
      yearBuilt: (json['yearBuilt'] ?? json['yearManufactured'])?.toString(),
      details: json['details']?.toString(),
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
  final String? details;
  final String? yearManufactured;

  Equipment({
    required this.id,
    required this.name,
    required this.category,
    this.status,
    this.condition,
    this.dailyRate,
    required this.images,
    this.details,
    this.yearManufactured,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      status: json['status']?.toString(),
      condition: json['condition']?.toString(),
      dailyRate: json['dailyRate']?.toString(),
      images: parseImageList(json['images'] ?? json['image']),
      details: json['details']?.toString(),
      yearManufactured: json['yearManufactured']?.toString(),
    );
  }
}

List<String> parseImageList(dynamic raw) {
  if (raw == null) return [];
  if (raw is List) {
    return raw
        .expand((item) {
          if (item is String) {
            return item.split(',');
          }
          return [item.toString()];
        })
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty && s.startsWith('http'))
        .toList();
  }
  if (raw is String) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return [];
    if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
      try {
        final decoded = json.decode(trimmed);
        if (decoded is List) {
          return parseImageList(decoded);
        }
      } catch (_) {}
    }
    return trimmed
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty && s.startsWith('http'))
        .toList();
  }
  return [];
}
