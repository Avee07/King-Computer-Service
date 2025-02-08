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

  // 📌 Convert from JSON (Handles null values)
  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Name', // ✅ Default value if null
      phone: json['phone'] ?? 'Unknown Phone', // ✅ Default value if null
      address: json['address'] ?? 'Unknown Address', // ✅ Default value if null
    );
  }

  // 📌 Convert to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'address': address,
      };
}
