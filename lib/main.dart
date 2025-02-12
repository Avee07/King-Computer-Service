import 'package:client_details_app/view/auth/login_screen.dart';
import 'package:client_details_app/view/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'controller/drive_auth_controller.dart';
import 'controller/schedule_export.dart';
import 'firebase_options.dart';
import 'controller/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ Initialize AuthController
  Get.put(AuthController());
  await DriveAuthController.checkDriveCredentials(); // ✅ Test JSON Load

  Scheduler.scheduleAutoExport(); // ✅ Auto-export on last day of month
  runApp(MyApp());
}

// ✅ Wrap App in GetMaterialApp
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: Get.key, // ✅ Ensures contextless navigation works
      home: AuthCheckScreen(), // ✅ Automatically redirects based on login state
    );
  }
}

// ✅ Authentication Check & Redirect
class AuthCheckScreen extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  AuthCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return authController.isLoggedIn.value ? HomeScreen() : LoginScreen();
    });
  }
}
  
  // In the code above, we have: 
  
  // Created a  MyApp  widget that wraps the entire app in  GetMaterialApp . 
  // Initialized the  AuthController  in the  main  function. 
  // Created an  AuthCheckScreen  widget that checks the login state and redirects to the  HomeScreen  or  LoginScreen  accordingly. 
  
  // The  AuthCheckScreen  widget listens to the  isLoggedIn  variable in the  AuthController  and displays the  HomeScreen  if the user is logged in, or the  LoginScreen  if the user is not logged in. 
  // The  AuthController  class is responsible for handling user authentication, including registering, logging in, and logging out users. 
  // The  HomeScreen  widget displays the main screen of the app, which contains buttons to register clients, manage clients, and export data. 
  // The  LoginScreen  widget allows users to log in, and the  RegisterScreen  widget allows users to register. 
  // The  Firebase.initializeApp  function initializes Firebase with the default options for the current platform. 
  // The  GetMaterialApp  widget is used to wrap the entire app and enable contextless navigation with GetX. 
  // The  Get.key  property is used to set the navigator key for the app, which is required for contextless navigation to work correctly. 
  // The  Obx  widget is used to listen to changes in the  isLoggedIn  variable in the  AuthController  and update the UI accordingly. 
  // Conclusion 
  // In this tutorial, we covered how to build a client details app using Flutter and Firebase. We implemented user authentication, client registration, client management, and data export features. 
  // We used the GetX package to manage state, navigation, and dependency injection in the app. GetX provides a simple and efficient way to build Flutter apps with minimal boilerplate code. 
  // By following this tutorial, you should now have a good understanding of how to build a client details app with Flutter and Firebase using the GetX package. 
  // To learn more about Flutter and Firebase, check out the following resources: 
  
  // Flutter Documentation
  // Firebase Documentation
  // GetX Documentation
  
  // Thanks for reading! 
