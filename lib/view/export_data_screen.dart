import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/export_controller.dart';

class ExportDataScreen extends StatelessWidget {
  final ExportController exportController = Get.put(ExportController());

  ExportDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Export Data")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Month & Year",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            // 📆 Month Selection
            _buildDropdown(
              label: "Month",
              icon: Icons.calendar_month,
              value: exportController.selectedMonth.value,
              items: List.generate(12, (index) {
                return DropdownMenuItem(
                  value: index + 1,
                  child: Text(exportController.monthNames[index]),
                );
              }),
              onChanged: (value) {
                if (value != null) {
                  exportController.selectedMonth.value = value;
                }
              },
            ),

            const SizedBox(height: 15),

            // 📅 Year Selection
            _buildDropdown(
              label: "Year",
              icon: Icons.date_range,
              value: exportController.selectedYear.value,
              items: List.generate(5, (index) {
                int year = DateTime.now().year - index;
                return DropdownMenuItem(value: year, child: Text("$year"));
              }),
              onChanged: (value) {
                if (value != null) {
                  exportController.selectedYear.value = value;
                }
              },
            ),

            const SizedBox(height: 30),

            // 📤 Export Button with Loading
            Obx(() => Center(
                  child: ElevatedButton.icon(
                    onPressed: exportController.isExporting.value
                        ? null
                        : () => exportController.exportToExcel(),
                    icon: exportController.isExporting.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.file_download),
                    label: Text(exportController.isExporting.value
                        ? "Exporting..."
                        : "Export to Excel"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  // 🔹 Custom Dropdown UI
  Widget _buildDropdown<T>({
    required String label,
    required IconData icon,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              isExpanded: true,
              value: value,
              items: items,
              onChanged: onChanged,
              icon: const Icon(Icons.arrow_drop_down),
            ),
          ),
        ),
      ],
    );
  }
}
