import 'package:client_details_app/controller/auth_controller.dart'
    show AuthController;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/auto_export_controller.dart';
import 'admin/admin_screen.dart';
import 'client_screen.dart';
import '../controller/client_controller.dart';
import 'export_data_screen.dart';

class HomeScreen extends StatelessWidget {
  final ClientController clientController = Get.put(ClientController());
  final AuthController authController = Get.find<AuthController>();
  final AutoExportController autoexportController = AutoExportController();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("King Computer Service Manager"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authController.logoutUser(),
          )
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double buttonSize = constraints.maxWidth > 600
              ? 200
              : 150; // Adjust size for bigger screens
          double spacing = constraints.maxWidth > 600
              ? 40
              : 20; // More space on wider screens

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  if (user != null && user.email == "admin@kcs.com")
                    ElevatedButton.icon(
                      onPressed: () {
                        Get.to(() => AdminPermissionsScreen());
                      },
                      icon: Icon(Icons.admin_panel_settings,
                          size: 28, color: Colors.white),
                      label: Text("Admin Panel",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  SizedBox(height: 100),
                  Wrap(
                    spacing: spacing, // Space between buttons horizontally
                    runSpacing: spacing, // Space between buttons vertically
                    alignment: WrapAlignment.center,
                    children: [
                      _buildSquareButton(
                          "Register Here", Icons.add, Colors.blue, buttonSize,
                          () {
                        _showAddClientDialog(context);
                      }),
                      _buildSquareButton("Manage Clients", Icons.people,
                          Colors.green, buttonSize, () {
                        Get.to(() => ClientScreen());
                      }),
                      if (user != null && user.email == "admin@kcs.com")
                        _buildSquareButton("Export Data", Icons.download,
                            Colors.orange, buttonSize, () {
                          Get.to(() => ExportDataScreen());
                        }),
                      // ElevatedButton(
                      //   onPressed: () {
                      //     AutoExportController().exportAndUpload(2, 2025);
                      //     Get.snackbar(
                      //         "Export", "Export started for February 2025!");
                      //     // () async {
                      //     //   int month = DateTime.now().month; // Use current month
                      //     //   int year = DateTime.now().year; // Use current year
                      //     //   await autoexportController.exportAndUpload(month, year);
                      //     //   Get.snackbar(
                      //     //       "✅ Success", "Manual export & upload completed.");
                      //   },
                      //   child: const Text("Trigger Export & Upload"),
                      // ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 🛠️ Reusable Responsive Button Widget
  Widget _buildSquareButton(String text, IconData icon, Color color,
      double size, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: size * 0.3, color: Colors.white), // Scale icon size
            const SizedBox(height: 10),
            Text(
              text,
              style: TextStyle(
                  fontSize: size * 0.15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // 🛠 Add Client & Product Issue Dialog
  void _showAddClientDialog(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController phoneController = TextEditingController();
    TextEditingController addressController = TextEditingController();
    TextEditingController serialController = TextEditingController();
    TextEditingController modelController = TextEditingController();
    TextEditingController issueController = TextEditingController();

    Get.defaultDialog(
      title: "Register Client & Product",
      content: Container(
        width: Get.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: Get.height * 0.7,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(nameController, "Client Name", Icons.person),
              _buildTextField(phoneController, "Phone", Icons.phone,
                  keyboardType: TextInputType.phone),
              _buildTextField(addressController, "Address", Icons.location_on),

              const Divider(),

              _buildTextField(
                  serialController, "Serial Number", Icons.confirmation_number),
              _buildTextField(modelController, "Model", Icons.devices),
              _buildTextField(issueController, "Issue", Icons.report_problem),

              const SizedBox(height: 20), // ✅ Adds spacing at the bottom
            ],
          ),
        ),
      ),
      textConfirm: "Save",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.blue,
      onConfirm: () {
        if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
          clientController.addClientWithProduct(
              nameController.text,
              phoneController.text,
              addressController.text,
              serialController.text,
              modelController.text,
              issueController.text,
              // ✅ Default Status:
              "Registered");
          Get.back(); // Close dialog
        }
      },
    );
  }

// 🛠️ Reusable Styled Text Field
  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
