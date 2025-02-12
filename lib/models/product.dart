import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  String id;
  String clientId;
  String serialNumber;
  String model;
  String issue;
  String status;
  double? repairCost;
  DateTime serviceDate;
  DateTime? serviceClosureDate;

  Product({
    required this.id,
    required this.clientId,
    required this.serialNumber,
    required this.model,
    required this.issue,
    required this.status,
    this.repairCost,
    required this.serviceDate,
    this.serviceClosureDate,
  });

  // ✅ Convert to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'clientId': clientId,
        'serialNumber': serialNumber,
        'model': model,
        'issue': issue,
        'status': status,
        'repairCost': repairCost ?? 0,
        'serviceDate': serviceDate.toIso8601String(),
        'serviceClosureDate': serviceClosureDate?.toIso8601String(),
      };

  // ✅ Handle Different Date Formats
  factory Product.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic date) {
      if (date is Timestamp) {
        return date.toDate();
      } else if (date is String) {
        return DateTime.tryParse(date) ?? DateTime.now();
      } else {
        return DateTime.now();
      }
    }

    return Product(
      id: json['id'],
      clientId: json['clientId'],
      serialNumber: json['serialNumber'],
      model: json['model'],
      issue: json['issue'],
      status: json['status'],
      repairCost: (json['repairCost'] ?? 0).toDouble(),
      serviceDate: parseDate(json['serviceDate']),
      serviceClosureDate: json['serviceClosureDate'] != null
          ? parseDate(json['serviceClosureDate'])
          : null,
    );
  }
}
