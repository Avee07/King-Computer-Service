import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import 'package:flutter/services.dart' show rootBundle;
import 'drive_upload_controller.dart';

class AutoExportController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 📌 Fetch & Export Data
  Future<void> exportAndUpload(int month, int year) async {
    try {
      DateTime firstDate = DateTime(year, month, 1);
      DateTime lastDate = DateTime(year, month + 1, 0);

      var clientSnapshot = await _db.collection("clients").get();
      Map<String, dynamic> clientMap = {
        for (var doc in clientSnapshot.docs) doc.id: doc.data()
      };

      var productSnapshot = await _db
          .collection("products")
          .where("serviceDate",
              isGreaterThanOrEqualTo: firstDate.toIso8601String())
          .where("serviceDate", isLessThanOrEqualTo: lastDate.toIso8601String())
          .get();

      var products = productSnapshot.docs.map((doc) => doc.data()).toList();
      if (products.isEmpty) {
        print("❌ No data to export.");
        return;
      }

      var excel = Excel.createExcel();
      Sheet sheet = excel['Data'];

      sheet.appendRow([
        TextCellValue("Client Name"),
        TextCellValue("Phone"),
        TextCellValue("Address"),
        TextCellValue("Product Model"),
        TextCellValue("Serial Number"),
        TextCellValue("Issue"),
        TextCellValue("Service Date"),
        TextCellValue("Status"),
        TextCellValue("Service Closure Date"),
        TextCellValue("Repair Cost"),
      ]);
      for (var product in products) {
        String clientId = product['clientId'] ?? "UNKNOWN_ID";
        var client = clientMap[clientId];

        if (client == null) {
          print("⚠ WARNING: No client found for clientId: $clientId");
          client = {"name": "Unknown", "phone": "", "address": ""};
        }

        sheet.appendRow([
          TextCellValue(client["name"] ?? "Unknown"),
          TextCellValue(client["phone"] ?? ""),
          TextCellValue(client["address"] ?? ""),
          TextCellValue(product["model"] ?? ""),
          TextCellValue(product["serialNumber"] ?? ""),
          TextCellValue(product["issue"] ?? ""),
          TextCellValue(product["serviceDate"] ?? ""),
          TextCellValue(product["status"] ?? ""),
          TextCellValue(product["serviceClosureDate"] ?? ""),
          TextCellValue(product["repairCost"]?.toString() ?? "0"),
        ]);
      }

      if (kIsWeb) {
        await _exportForWeb(excel);
      } else {
        await _exportForDesktopOrMobile(excel, month, year);
      }
    } catch (e) {
      print("❌ Error exporting data: $e");
    }
  }

  // ✅ Web: Save file in Browser (Fix MissingPluginException)
  Future<void> _exportForWeb(Excel excel) async {
    Uint8List fileBytes = Uint8List.fromList(excel.save()!);
    // final blob = html.Blob([fileBytes]);
    // final url = html.Url.createObjectUrlFromBlob(blob);
    // final anchor = html.AnchorElement(href: url)
    //   ..setAttribute("download",
    //       "Client_Report_${DateTime.now().month}_${DateTime.now().year}.xlsx")
    //   ..click();
    // html.Url.revokeObjectUrl(url);
    print("✅ File downloaded successfully on Web!");

    // ✅ Upload to Google Drive
    await DriveUploadController().uploadToDrive(fileBytes,
        "Client_Report_${DateTime.now().month}_${DateTime.now().year}.xlsx");
  }

  // ✅ Mobile & Desktop: Save to Device
  Future<void> _exportForDesktopOrMobile(
      Excel excel, int month, int year) async {
    Directory? directory;

    if (Platform.isAndroid || Platform.isIOS) {
      directory = await getExternalStorageDirectory(); // Mobile Storage
    } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      directory = await getApplicationDocumentsDirectory(); // Desktop Storage
    }

    if (directory == null) {
      print("❌ Error: Could not get storage directory.");
      return;
    }

    String filePath = "${directory.path}/Client_Report_$month$year.xlsx";
    File file = File(filePath);
    file.writeAsBytesSync(excel.save()!);
    print("✅ File saved successfully at: $filePath");

    // ✅ Upload to Google Drive
    // await DriveUploadController().uploadToDrive(file);
  }
}
