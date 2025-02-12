import 'dart:typed_data';
import 'package:client_details_app/controller/drive_auth_controller.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';

class DriveUploadController {
  // 📌 Upload file to Google Drive from Uint8List (for Web)
  Future<void> uploadToDrive(Uint8List fileBytes, String fileName) async {
    try {
      var driveApi = await _getDriveApi();
      if (driveApi == null) {
        print("❌ Drive API authentication failed.");
        return;
      }

      var driveFile = drive.File();
      driveFile.name = fileName;
      driveFile.parents = ["1O_CqC3UhO08kmaJ8JAVQsf18f9EkhuPZ"];

      var media = drive.Media(Stream.value(fileBytes), fileBytes.length);
      var uploadedFile =
          await driveApi.files.create(driveFile, uploadMedia: media);

      print("✅ File uploaded successfully: ${uploadedFile.name}");
    } catch (e) {
      print("❌ Upload to Drive Failed: $e");
    }
  }

  // 📌 Get authenticated Drive API instance
  Future<drive.DriveApi?> _getDriveApi() async {
    try {
      final auth = await DriveAuthController.getDriveApi();
      return auth;
    } catch (e) {
      print("❌ Google Drive Auth Error: $e");
      return null;
    }
  }
}
