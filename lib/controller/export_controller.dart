import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../utils/file_saver.dart'; // ✅ Conditional Import

class ExportController extends GetxController {
  var selectedMonth = DateTime.now().month.obs;
  var selectedYear = DateTime.now().year.obs;
  var isExporting = false.obs;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<String> monthNames = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];

  // 📌 Export Data to Excel
  Future<void> exportToExcel() async {
    try {
      isExporting.value = true;
      int month = selectedMonth.value;
      int year = selectedYear.value;

      DateTime firstDate = DateTime(year, month, 1);
      DateTime lastDate = DateTime(year, month + 1, 0);

      // 🔍 Fetch Clients & Map Them by ID
      var clientSnapshot = await _db.collection("clients").get();
      Map<String, dynamic> clientMap = {
        for (var doc in clientSnapshot.docs) doc.id: doc.data()
      };

      // 🔍 Fetch Products for the Selected Month (Firestore uses Timestamp)
      var productSnapshot = await _db
          .collection("products")
          .where("serviceDate",
              isGreaterThanOrEqualTo: Timestamp.fromDate(firstDate))
          .where("serviceDate",
              isLessThanOrEqualTo: Timestamp.fromDate(lastDate))
          .get();
      var products = productSnapshot.docs.map((doc) => doc.data()).toList();

      if (products.isEmpty) {
        Get.snackbar("No Data", "No products found for the selected month.");
        return;
      }

      // 📊 Create Excel
      var excel = Excel.createExcel();
      Sheet sheet = excel['Client Data'];

      // 📌 Add Header Row
      sheet.appendRow([
        TextCellValue("Client Name"),
        TextCellValue("Phone"),
        TextCellValue("Address"),
        TextCellValue("Product Model"),
        TextCellValue("Serial Number"),
        TextCellValue("Issue"),
        TextCellValue("Status"),
        TextCellValue("Service Date"),
        TextCellValue("Repair Cost")
      ]);

      // 📌 Add Data Rows
      for (var product in products) {
        String clientId = product['clientId'] ?? "UNKNOWN_ID";
        var client = clientMap[clientId];

        client ??= {"name": "Unknown", "phone": "", "address": ""};

        sheet.appendRow([
          TextCellValue(client["name"] ?? "Unknown"),
          TextCellValue(client["phone"] ?? ""),
          TextCellValue(client["address"] ?? ""),
          TextCellValue(product["model"] ?? ""),
          TextCellValue(product["serialNumber"] ?? ""),
          TextCellValue(product["issue"] ?? ""),
          TextCellValue(product["status"] ?? ""),
          TextCellValue(
              (product["serviceDate"] as Timestamp?)?.toDate().toString() ??
                  ""),
          TextCellValue(product["repairCost"]?.toString() ?? "0"),
        ]);
      }

      // 📤 Save File (Handles Web & Desktop Separately)
      var fileBytes = excel.save();
      if (fileBytes != null) {
        await saveFile(
            "Client_Report_${monthNames[selectedMonth.value - 1]}_${selectedYear.value}.xlsx",
            fileBytes);
      }

      Get.snackbar("Success", "Excel file exported successfully!");
    } catch (e) {
      print("❌ Error exporting data: $e");
      Get.snackbar("Error", "Failed to export data.");
    } finally {
      isExporting.value = false;
    }
  }
}
