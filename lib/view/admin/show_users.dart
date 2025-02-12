import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/admin_service.dart';

class ShowUsersScreen extends StatefulWidget {
  const ShowUsersScreen({super.key});

  @override
  _ShowUsersScreenState createState() => _ShowUsersScreenState();
}

class _ShowUsersScreenState extends State<ShowUsersScreen> {
  final AdminServices _adminServices = AdminServices();
  List<Map<String, dynamic>> _admins = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAdmins();
  }

  /// Fetch all registered admins
  Future<void> _fetchAdmins() async {
    setState(() => _isLoading = true);
    List<Map<String, dynamic>> admins = await _adminServices.fetchUsers();
    setState(() {
      _admins = admins;
      _isLoading = false;
    });
  }

  /// Show confirmation dialog before deleting an admin
  void _confirmDeleteAdmin(String uid, String email) {
    Get.defaultDialog(
      title: "Delete Admin?",
      middleText: "Are you sure you want to delete $email?",
      textCancel: "Cancel",
      textConfirm: "Delete",
      confirmTextColor: Colors.white,
      onConfirm: () async {
        await _adminServices.deleteAdmin(uid, email);
        _fetchAdmins(); // Refresh list
        Get.back();
      },
    );
  }

  /// Send password reset email
  void _resetPassword(String email) async {
    await _adminServices.resetAdminPassword(email);
  }

  /// Show dialog to update admin password
  void _showPasswordUpdateDialog(String uid) {
    TextEditingController passwordController = TextEditingController();

    Get.defaultDialog(
      title: "Update Password",
      content: Column(
        children: [
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(labelText: "New Password"),
          ),
        ],
      ),
      textCancel: "Cancel",
      textConfirm: "Update",
      confirmTextColor: Colors.white,
      onConfirm: () async {
        String newPassword = passwordController.text.trim();
        if (newPassword.length < 6) {
          Get.snackbar("Error", "Password must be at least 6 characters long");
          return;
        }
        await _adminServices.updateAdminPassword(uid, newPassword);
        Get.back(); // Close the dialog
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Manage Admins")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _admins.isEmpty
              ? Center(child: Text("No admins found"))
              : ListView.builder(
                  itemCount: _admins.length,
                  itemBuilder: (context, index) {
                    final admin = _admins[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      child: ListTile(
                        title: Text(admin["email"]),
                        subtitle: Text(
                          "Created: ${admin["createdAt"] != null ? (admin["createdAt"] as Timestamp).toDate().toLocal().toString() : 'N/A'}",
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.lock_reset, color: Colors.blue),
                              onPressed: () =>
                                  _showPasswordUpdateDialog(admin["uid"]),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDeleteAdmin(
                                  admin["uid"], admin["email"]),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
