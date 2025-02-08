import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_launch/flutter_launch.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/product.dart';

class ProductController extends GetxController {
  var products = <Product>[].obs;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Fetch products for a specific client
  void fetchProducts(String clientId) async {
    try {
      var snapshot = await _db
          .collection("products")
          .where("clientId", isEqualTo: clientId)
          .get();
      products.value = snapshot.docs.map((doc) {
        var data = doc.data();
        return Product.fromJson({
          'id': doc.id,
          'clientId': data['clientId'] ?? '',
          'serialNumber': data['serialNumber'] ?? '',
          'model': data['model'] ?? '',
          'issue': data['issue'] ?? '',
          'status': data['status'] ?? 'Registered',
          'repairCost': data['repairCost'] ?? 0,
        });
      }).toList();
    } catch (e) {
      print("Error fetching products: $e");
    }
  }

  // Add Product to Firestore
  Future<void> addProduct(String clientId, String serialNumber, String model,
      String issue, String status) async {
    String id = _db.collection("products").doc().id;
    Product newProduct = Product(
      id: id,
      clientId: clientId,
      serialNumber: serialNumber,
      model: model,
      issue: issue,
      status: status,
      serviceDate: DateTime.now(),
    );

    await _db.collection("products").doc(id).set(newProduct.toJson());
    fetchProducts(clientId); // Refresh list
  }

  // 📌 Update Product Status & Repair Cost
  Future<void> markAsRepaired(
      Product product, double repairCost, String phoneNumber) async {
    try {
      await _db.collection("products").doc(product.id).update({
        "status": "Repaired",
        "repairCost": repairCost,
      });

      // ✅ Update local list
      product.status = "Repaired";
      product.repairCost = repairCost;
      products.refresh();

      // ✅ Send WhatsApp Notification
      sendRepairWhatsAppMessage(phoneNumber, product.model, repairCost);
    } catch (e) {
      print("Error updating product status: $e");
    }
  }

  // 📌 Send WhatsApp Message
  Future<void> sendRepairWhatsAppMessage(
      String phone, String model, double repairCost) async {
    String businessName = "King Computer Services ";
    String address =
        "Address: 2nd floor, Anuvrat Plaza, C4/A, Phool Chowk Main Rd, near Hotel Venkatesh, Nayapara, Raipur, Chhattisgarh 492001";
    String contact = "Phone: 093025 07090";

    String feedbackLink =
        "King Computer Services (Printer Service Center) would love your feedback. "
        "Post a review to our profile: https://g.page/r/Cc7L4S2Ar1H4EBE/review";
    String message = "$businessName\n\n$address\n\n$contact\n\n"
        "Hello ,\nYour product ($model) has been repaired.\n"
        "\n\nThank you!\n\n$feedbackLink";

    String url = "https://wa.me/$phone?text=${Uri.encodeComponent(message)}";

    if (!kIsWeb) {
      if (Platform.isAndroid) {
        // ✅ Android: Use `flutter_launch`
        try {
          await FlutterLaunch.launchWhatsapp(
              phone: "+91$phone", message: message);
        } catch (e) {
          print("WhatsApp message failed on Android: $e");
        }
      } else if (Platform.isIOS ||
          Platform.isWindows ||
          Platform.isLinux ||
          Platform.isMacOS) {
        // ✅ iOS, Windows, Linux, macOS: Use `url_launcher`
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url));
        } else {
          print("Could not open WhatsApp.");
        }
      }
    } else {
      // ✅ Web: Use WhatsApp Web
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        print("WhatsApp Web could not be opened.");
      }
    }
  }
}
