import 'dart:io';
import 'package:file_picker/file_picker.dart';

Future<void> saveFile(String fileName, List<int> fileBytes) async {
  String? outputFile = await FilePicker.platform.saveFile(
    dialogTitle: 'Save Excel File',
    fileName: fileName,
  );
  if (outputFile != null) {
    File(outputFile).writeAsBytesSync(fileBytes);
  }
}
