import 'package:client_details_app/view/auth/login_screen.dart';
import 'package:client_details_app/view/homescreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var isLoading = false.obs;
  var isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkAuthState();
  }

  // ✅ Check Authentication State
  void _checkAuthState() {
    _auth.authStateChanges().listen((User? user) {
      isLoggedIn.value = user != null;
      if (user == null) {
        Future.delayed(Duration.zero, () => Get.offAll(() => LoginScreen()));
      } else {
        Future.delayed(Duration.zero, () => Get.offAll(() => HomeScreen()));
      }
    });
  }

  // ✅ Register User
  Future<void> registerUser(String email, String password) async {
    try {
      isLoading.value = true;
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      Get.snackbar("Success", "User Registered Successfully!");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Login User
  Future<void> loginUser(String email, String password) async {
    try {
      isLoading.value = true;
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Get.snackbar("Success", "Login Successful!");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Logout User
  Future<void> logoutUser() async {
    await _auth.signOut();
    Get.offAll(() => LoginScreen());
  }
}
