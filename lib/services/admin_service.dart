import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AdminServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// ✅ Fetch all registered admins from Firestore
  Future<List<Map<String, dynamic>>> fetchUsers() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection("admins").get();

      List<Map<String, dynamic>> users = snapshot.docs.map((doc) {
        return {
          "uid": doc.id,
          "email": doc["email"],
          "createdAt": doc["createdAt"],
        };
      }).toList();

      return users;
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch users: $e",
          snackPosition: SnackPosition.BOTTOM);
      return [];
    }
  }

  /// ✅ Delete all documents from a Firestore collection
  Future<void> deleteCollection(String collectionPath) async {
    final collection = _firestore.collection(collectionPath);
    final snapshots = await collection.get();

    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }
    print("✅ Collection '$collectionPath' deleted successfully!");
  }

  /// ✅ Delete all client & product data
  Future<void> deleteAllCollections() async {
    await deleteCollection("clients");
    await deleteCollection("products");

    // Show success message
    Get.snackbar("Success", "All Firestore data deleted!",
        snackPosition: SnackPosition.BOTTOM);
  }

  /// ✅ Check if email is already registered
  Future<bool> isEmailAlreadyRegistered(String email) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty; // Returns true if email exists
    } catch (e) {
      Get.snackbar("Error", "Invalid email format or network issue",
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  /// ✅ Add new admin if email is not registered
  Future<void> addNewAdmin(String email, String password) async {
    if (await isEmailAlreadyRegistered(email)) {
      Get.snackbar("Error", "This email is already registered!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error);
      return;
    }

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      // ✅ Save admin details in Firestore
      await _firestore.collection("admins").doc(uid).set({
        "email": email,
        "createdAt": FieldValue.serverTimestamp(),
      });

      Get.snackbar("Success", "User added successfully!",
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  /// ✅ Delete an admin from both Firebase Authentication & Firestore
  Future<void> deleteAdmin(String uid, String email) async {
    try {
      // 🔹 Delete user from Firestore
      await _firestore.collection("admins").doc(uid).delete();

      // 🔹 Delete user from Firebase Authentication
      User? user = _auth.currentUser;
      if (user != null && user.email == email) {
        await user.delete();
      }

      Get.snackbar("Success", "Admin deleted successfully!",
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar("Error", "Failed to delete admin: $e",
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  /// ✅ Reset admin password
  Future<void> resetAdminPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      Get.snackbar("Success", "Password reset email sent!",
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  /// ✅ Update an admin's password (directly set by another admin)
  Future<void> updateAdminPassword(String uid, String newPassword) async {
    try {
      // Get the user by UID
      User? user = _auth.currentUser;
      if (user == null) {
        Get.snackbar("Error", "No authenticated admin found",
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      // If the current user is trying to change their own password
      if (user.uid == uid) {
        await user.updatePassword(newPassword);
        Get.snackbar("Success", "Password updated successfully!",
            snackPosition: SnackPosition.BOTTOM);
      } else {
        // Change password in Firestore for tracking purposes
        await _firestore.collection("users").doc(uid).update({
          "password": newPassword,
        });

        Get.snackbar("Success", "Admin password updated successfully!",
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }
}
