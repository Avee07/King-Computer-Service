import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_launch/flutter_launch.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/client.dart';
import '../models/product.dart';

class ClientController extends GetxController {
  var clients = <Client>[].obs;
  var filteredClients = <Client>[].obs;
  var isLoading = true.obs; // ✅ Track loading state

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    fetchClients(); // ✅ Fetch clients automatically when the controller is created
  }

  // Fetch Clients from Firestore
  void fetchClients() async {
    try {
      isLoading.value = true; // 🔄 Show loader
      var snapshot = await _db.collection("clients").get();

      if (snapshot.docs.isEmpty) {
        Get.snackbar(
          "No Clients",
          "No clients found in the database.",
          snackPosition: SnackPosition.BOTTOM,
        );
        // print("⚠ No clients found!");
        isLoading.value = false; // ✅ Hide loader
      } else {
        print("✅ Clients fetched: ${snapshot.docs.length}");
      }

      clients.value = snapshot.docs.map((doc) {
        var data = doc.data();
        return Client.fromJson({
          'id': doc.id,
          'name': data['name'] ?? 'Unknown Name',
          'phone': data['phone'] ?? 'Unknown Phone',
          'address': data['address'] ?? 'Unknown Address',
        });
      }).toList();

      // ✅ Update `filteredClients` so UI loads data
      filteredClients.value = List.from(clients);
    } catch (e) {
      Get.snackbar(
        "Error",
        "Error fetching clients: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
      // print("❌ Error fetching clients: $e");
    } finally {
      isLoading.value = false; // ✅ Hide loader
    }
  }

  // Search Clients by Name or Serial Number
  Future<void> searchClients(String query) async {
    if (query.isEmpty) {
      filteredClients.value = clients;
      return;
    }

    // Search by client name
    var nameFiltered = clients
        .where(
            (client) => client.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    // Search by product serial number
    var snapshot = await _db
        .collection("products")
        .where('serialNumber', isEqualTo: query)
        .get();

    List<String> matchedClientIds =
        snapshot.docs.map((doc) => doc.data()['clientId'].toString()).toList();
    var serialFiltered = clients
        .where((client) => matchedClientIds.contains(client.id))
        .toList();

    filteredClients.value = {...nameFiltered, ...serialFiltered}.toList();
  }

  // Update Client-Details to Firestore
Future<void> updateClientDetails(
    String clientId, String name, String phone, String address) async {
  try {
    await _db.collection("clients").doc(clientId).update({
      "name": name,
      "phone": phone,
      "address": address,
    });

    // ✅ Update the local list
    var index = clients.indexWhere((c) => c.id == clientId);
    if (index != -1) {
      clients[index] = clients[index].copyWith(
        name: name,
        phone: phone,
        address: address,
      );
      clients.refresh();
    }

    Get.snackbar("Success", "Client details updated successfully!");
  } catch (e) {
    print("❌ Error updating client details: $e");
    Get.snackbar("Error", "Failed to update client details.");
  }
}

  // Add Client & Product Together and Send WhatsApp Message
  Future<void> addClientWithProduct(String name, String phone, String address,
      String serialNumber, String model, String issue, String status) async {
    try {
      // 🔍 Check if the client already exists
      var clientQuery = await _db
          .collection("clients")
          .where("name", isEqualTo: name)
          .where("phone", isEqualTo: phone)
          .where("address", isEqualTo: address)
          .get();

      String clientId;

      if (clientQuery.docs.isNotEmpty) {
        // ✅ Client already exists, use existing ID
        clientId = clientQuery.docs.first.id;
        print("🔄 Existing client found: $clientId");
      } else {
        // 🆕 New client, create a new ID
        clientId = _db.collection("clients").doc().id;
        Client newClient =
            Client(id: clientId, name: name, phone: phone, address: address);
        await _db.collection("clients").doc(clientId).set(newClient.toJson());
        print("✅ New client created: $clientId");
      }

      // 🔹 Create Product Object
      Product newProduct = Product(
        id: _db.collection("products").doc().id, // Auto-generate ID
        clientId: clientId, // Link product to existing or new client
        serialNumber: serialNumber,
        model: model,
        issue: issue,
        status: status,
        serviceDate: DateTime.now(),
      );

      // 🔹 Store Product in Firestore
      await _db
          .collection("products")
          .doc(newProduct.id)
          .set(newProduct.toJson());

      fetchClients(); // 🔄 Refresh Client List

      // 📲 Send WhatsApp Message
      sendWhatsAppMessage(phone, name, model, serialNumber);
    } catch (e) {
      print("❌ Error adding client & product: $e");
    }
  }

  // Function to Send WhatsApp Message
  Future<void> sendWhatsAppMessage(
      String phone, String name, String model, String serialNumber) async {
    String businessName = "King Computer Services";
    String address =
        "Address: 2nd floor, Anuvrat Plaza, C4/A, Phool Chowk Main Rd, near Hotel Venkatesh, Nayapara, Raipur, Chhattisgarh 492001";
    String contact = "Phone: 093025 07090";
    String date =
        DateTime.now().toLocal().toString().split(' ')[0]; // Today's Date

    String message = "$businessName\n\n$address\n\n$contact\n\n"
        "Hello $name,\nYour product ($model, Serial: $serialNumber) has been registered with us on date ($date). Thank you!";

    String url = "https://wa.me/$phone?text=${Uri.encodeComponent(message)}";

    if (!kIsWeb) {
      if (Platform.isAndroid) {
        // ✅ Android: Use `flutter_launch`
        try {
          await FlutterLaunch.launchWhatsapp(
              phone: "+91$phone", message: message);
        } catch (e) {
          Get.snackbar(
            "Error",
            "WhatsApp message failed on Android: $e",
            snackPosition: SnackPosition.BOTTOM,
          );
          // print("WhatsApp message failed on Android: $e");
        }
      } else if (Platform.isIOS ||
          Platform.isWindows ||
          Platform.isLinux ||
          Platform.isMacOS) {
        // ✅ iOS, Windows, Linux, macOS: Use `url_launcher`
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url));
        } else {
          Get.snackbar(
            "Error",
            "Could not open WhatsApp.",
            snackPosition: SnackPosition.BOTTOM,
          );
          // print("Could not open WhatsApp.");
        }
      }
    } else {
      // ✅ Web: Use WhatsApp Web
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        Get.snackbar(
          "Error",
          "WhatsApp Web could not be opened.",
          snackPosition: SnackPosition.BOTTOM,
        );
        // print("WhatsApp Web could not be opened.");
      }
    }
  }
}
