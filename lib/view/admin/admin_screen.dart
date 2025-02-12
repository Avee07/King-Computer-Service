import 'package:client_details_app/view/admin/show_users.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/admin_service.dart';

class AdminPermissionsScreen extends StatefulWidget {
  const AdminPermissionsScreen({super.key});

  @override
  State<AdminPermissionsScreen> createState() => _AdminPermissionsScreenState();
}

class _AdminPermissionsScreenState extends State<AdminPermissionsScreen> {
  final AdminServices adminServices = AdminServices(); // Instance of service

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Permissions",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Manage Admin Settings",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Add New User
            ListTile(
              leading: Icon(Icons.person_add, color: Colors.green, size: 30),
              title: Text("Add New User"),
              trailing: Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () => _showAddAdminDialog(),
            ),
            Divider(),

            // // Change Permissions
            // ListTile(
            //   leading: Icon(Icons.lock, color: Colors.red, size: 30),
            //   title: Text("Change Permissions"),
            //   trailing: Icon(Icons.arrow_forward_ios, size: 18),
            //   onTap: () {},
            // ),
            // Divider(),

            // Remove Admin
            ListTile(
              leading:
                  Icon(Icons.verified_user, color: Colors.orange, size: 30),
              title: Text("Show all Users"),
              trailing: Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () {
                Get.to(() => ShowUsersScreen());
              },
            ),
            Divider(),

            // Delete All Data
            ListTile(
              leading: Icon(Icons.delete_forever, color: Colors.red, size: 30),
              title: Text("Delete All Data"),
              trailing: Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () => _showDeleteConfirmation(),
            ),
          ],
        ),
      ),
    );
  }

  /// Show confirmation dialog before deleting
  void _showDeleteConfirmation() {
    Get.defaultDialog(
      title: "Delete All Data?",
      middleText: "This action is irreversible. Are you sure?",
      textCancel: "Cancel",
      textConfirm: "Delete",
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back(); // Close dialog
        adminServices.deleteAllCollections();
      },
    );
  }

  /// Show Add Admin Dialog
  void _showAddAdminDialog() {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add New Admin"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                String email = emailController.text.trim();
                String password = passwordController.text.trim();

                if (email.isEmpty || password.isEmpty) {
                  Get.snackbar("Error", "Please fill in all fields",
                      snackPosition: SnackPosition.BOTTOM);
                  return;
                }

                await adminServices.addNewAdmin(email, password);
                Navigator.pop(context);
              },
              child: Text("Add User"),
            ),
          ],
        );
      },
    );
  }
}
