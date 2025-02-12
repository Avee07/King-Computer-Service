import 'dart:convert';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;

class DriveAuthController {
  static Future<drive.DriveApi?> getDriveApi() async {
    try {
      // Load Service Account Credentials from assets
      final String credentialsJson =
          await rootBundle.loadString('assets/drive_credentials.json');
      final credentials =
          ServiceAccountCredentials.fromJson(json.decode(credentialsJson));

      // Authenticate using Google APIs Auth
      final client = await clientViaServiceAccount(
          credentials, [drive.DriveApi.driveFileScope]);

      return drive.DriveApi(client);
    } catch (e) {
      print("❌ Google Drive Auth Error: $e");
      return null;
    }
  }

  static Future<void> checkDriveCredentials() async {
    try {
      final String credentialsJson =
          await rootBundle.loadString('assets/drive_credentials.json');
      print("✅ Drive Credentials Loaded Successfully!");
      print("📄 JSON Content: $credentialsJson");
    } catch (e) {
      print("❌ Google Drive Auth Error: $e");
    }
  }
}
