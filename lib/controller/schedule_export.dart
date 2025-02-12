import 'dart:async';
import 'package:get/get.dart';
import 'auto_export_controller.dart';

class Scheduler {
  static void scheduleAutoExport() {
    Timer.periodic(Duration(days: 1), (timer) {
      DateTime now = DateTime.now();
      if (now.day == DateTime(now.year, now.month + 1, 0).day) {
        // ✅ Last day of the month
        AutoExportController().exportAndUpload(now.month, now.year);
      }
    });
  }
}
