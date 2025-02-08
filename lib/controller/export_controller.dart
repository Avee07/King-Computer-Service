import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io' show File, Platform;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;

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

      // 🔍 Get first and last date of selected month
      DateTime firstDate = DateTime(year, month, 1);
      DateTime lastDate = DateTime(year, month + 1, 0); // Last day of month

      // 🔍 Fetch latest Clients
      var clientSnapshot = await _db.collection("clients").get();
      var clients = clientSnapshot.docs.map((doc) => doc.data()).toList();

      // 🔍 Fetch latest Products within the selected month (including today)
      var productSnapshot = await _db
          .collection("products")
          .where("serviceDate",
              isGreaterThanOrEqualTo: firstDate.toIso8601String())
          .where("serviceDate", isLessThanOrEqualTo: lastDate.toIso8601String())
          .get();
      var products = productSnapshot.docs.map((doc) => doc.data()).toList();
      print(products);
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
        var client = clients.firstWhere((c) => c['id'] == product['clientId'],
            orElse: () => {"name": "Unknown", "phone": "", "address": ""});

        sheet.appendRow([
          TextCellValue(client["name"] ?? ""),
          TextCellValue(client["phone"] ?? ""),
          TextCellValue(client["address"] ?? ""),
          TextCellValue(product["model"] ?? ""),
          TextCellValue(product["serialNumber"] ?? ""),
          TextCellValue(product["issue"] ?? ""),
          TextCellValue(product["status"] ?? ""),
          TextCellValue(product["serviceDate"] ?? ""),
          TextCellValue(product["repairCost"]?.toString() ?? "0"),
        ]);
      }

      // 📤 Save File (Handles Web & Mobile Separately)
      if (kIsWeb) {
        var fileBytes = excel.save();
        final blob = html.Blob([
          Uint8List.fromList(fileBytes!)
        ], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute(
              "download", "Client_Report_${monthNames[month - 1]}_$year.xlsx")
          ..click();
        html.Url.revokeObjectUrl(url);
        Get.snackbar("Success", "Excel file downloaded successfully!");
      } else {
        var fileBytes = excel.save();
        String? outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Save Excel File',
          fileName: 'Client_Report_${monthNames[month - 1]}_$year.xlsx',
        );

        if (outputFile != null) {
          File(outputFile).writeAsBytesSync(fileBytes!);
          Get.snackbar("Success", "Excel file exported successfully!");
        }
      }
    } catch (e) {
      print("Error exporting data: $e");
      Get.snackbar("Error", "Failed to export data.");
    } finally {
      isExporting.value = false;
    }
  }
}
