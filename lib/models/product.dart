class Product {
  String id;
  String clientId;
  String serialNumber;
  String model;
  String issue;
  String status;
  DateTime serviceDate;
  double? repairCost; // ✅ New field for repair cost

  Product({
    required this.id,
    required this.clientId,
    required this.serialNumber,
    required this.model,
    required this.issue,
    required this.status,
    required this.serviceDate,
    this.repairCost, // ✅ Nullable repair cost
  });

  // 🔹 Convert to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'clientId': clientId,
        'serialNumber': serialNumber,
        'model': model,
        'issue': issue,
        'status': status,
        'serviceDate': serviceDate.toIso8601String(),
        'repairCost': repairCost, // ✅ Save repair cost
      };

  // 🔹 Convert from JSON (Handles null values)
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      clientId: json['clientId'] ?? '',
      serialNumber: json['serialNumber'] ?? '',
      model: json['model'] ?? '',
      issue: json['issue'] ?? '',
      status: json['status'] ?? 'Registered',
      serviceDate: json['serviceDate'] != null
          ? DateTime.parse(json['serviceDate'])
          : DateTime.now(),
      repairCost: json['repairCost'] != null
          ? double.tryParse(json['repairCost'].toString())
          : null, // ✅ Handle repair cost as nullable
    );
  }
}
