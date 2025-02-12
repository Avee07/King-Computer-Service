class Client {
  String id;
  String name;
  String phone;
  String address;

  Client({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
  });

  // ✅ Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
    };
  }

  // ✅ Convert from JSON
  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
    );
  }

  // ✅ Add `copyWith` Method
  Client copyWith({String? name, String? phone, String? address}) {
    return Client(
      id: id, // Keep ID same
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }
}
