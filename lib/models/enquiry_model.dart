class EnquiryItem {
  final String id;
  final String name;
  final String type; // 'vessel' | 'equipment'
  final int quantity;
  final String? imageUrl;

  EnquiryItem({
    required this.id,
    required this.name,
    required this.type,
    required this.quantity,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'quantity': quantity,
    'imageUrl': imageUrl,
  };

  factory EnquiryItem.fromJson(Map<String, dynamic> json) => EnquiryItem(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    type: json['type']?.toString() ?? 'asset',
    quantity: json['quantity'] is int
        ? json['quantity']
        : int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
    imageUrl: json['imageUrl']?.toString(),
  );
}

class Enquiry {
  final String id;
  final DateTime createdAt;
  final String customerEmail;
  final String portLocation;
  final String notes;
  final String status; // 'Submitted', 'Under Review', 'Rates Dispatched'
  final List<EnquiryItem> items;

  Enquiry({
    required this.id,
    required this.createdAt,
    required this.customerEmail,
    required this.portLocation,
    required this.notes,
    this.status = 'Submitted',
    required this.items,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'customerEmail': customerEmail,
    'portLocation': portLocation,
    'notes': notes,
    'status': status,
    'items': items.map((i) => i.toJson()).toList(),
  };

  factory Enquiry.fromJson(Map<String, dynamic> json) => Enquiry(
    id: json['id']?.toString() ?? '',
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    customerEmail: json['customerEmail']?.toString() ?? '',
    portLocation: json['portLocation']?.toString() ?? '',
    notes: json['notes']?.toString() ?? '',
    status: json['status']?.toString() ?? 'Submitted',
    items: (json['items'] as List<dynamic>?)
        ?.map((item) => EnquiryItem.fromJson(item as Map<String, dynamic>))
        .toList() ?? [],
  );
}
