import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'HomeScreen.dart';
import 'LoginScreen.dart';



class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    requestNotificationPermission();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);

    // Navigate to the next screen after 2 seconds
    Future.delayed(Duration(seconds: 1), () {
      navigateToUserSelection();
   //   checkLoginStatus();
    });
  }

  void navigateToUserSelection() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/splash_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Image.asset(
            'assets/hairfixing_logo.png',
            width: 200,
            height: 200,
          ),
        ),
      ),
    );
  }

  Future<void> requestNotificationPermission() async {
    // Map<Permission, PermissionStatus> storageStatuses = await [
    //   Permission.storage,
    //   Permission.manageExternalStorage,
    // ].request();
    //
    // var storagePermission = storageStatuses[Permission.storage];
    // print('Storage permission is granted: $storagePermission');
    // var manageExternalStoragePermission = storageStatuses[Permission.manageExternalStorage];
    // print('Manage external storage permission is granted: $manageExternalStoragePermission');

    // Request location permission
    Map<Permission, PermissionStatus> locationStatuses = await [
      Permission.location,
    ].request();

    var locationPermission = locationStatuses[Permission.location];
    print('Location permission is granted: $locationPermission');



    if (locationPermission!.isGranted) {
      // Location permission granted, do something
    } else {
      // Location permission not granted, handle accordingly
      openAppSettings();
    }
  }


  Future<void> storeNotificationPermissionStatus(bool isGranted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationPermissionStatus', isGranted);
  }

  void checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    print('isLoggedIn: $isLoggedIn');
    if (isLoggedIn) {
      int? userId = prefs.getInt('userId'); // Retrieve the user ID
      int? roleId = prefs.getInt('userRoleId'); // Retrieve the role ID

      // if (userId != null && roleId != null) {
      if (userId != null ) {
        // Use the user ID and role ID as needed
        print('User ID: $userId, Role ID: $roleId');
        if (roleId == 2) {
          // Navigate to home screen for users with role ID 1
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          // Navigate to another screen for users with different role ID
          // For example, you might have a different screen for users with role ID 2
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()));

        }
      } else {
        // Handle the case where the user ID or role ID is not available
        print('User ID or Role ID not found in SharedPreferences');
      }
    } else {
      // If not logged in, navigate to the login screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

}
