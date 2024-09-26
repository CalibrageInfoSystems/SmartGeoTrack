import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartgetrack/LoginScreen.dart';
import 'package:smartgetrack/common_styles.dart';

import 'Common/Constants.dart';
import 'Database/DataSyncHelper.dart';


import 'Database/Palm3FoilDatabase.dart';
import 'HomeScreen.dart';



class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  static const String LOG_TAG = "SplashScreen";
  late Animation<double> _animation;
  Palm3FoilDatabase? palm3FoilDatabase;
  final List<Permission> permissionsRequired = [
    Permission.camera,
    Permission.location,
    Permission.phone,
    // Add other permissions if needed
  ];
  bool isLocationEnabled = false;
  bool isLogin = false;
  bool welcome = false;
  
  @override
  void initState() {
    super.initState();
    loadData();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    checkLocationEnabled();
    _requestPermissions();
    // Initialize AnimationController
    _animationController = AnimationController(
      duration: Duration(seconds: 3), // Duration for fade-in effect
      vsync: this,
    );

    // Define fade-in animation only
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInCirc,
    ));
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToMainLoginScreen();
      }
    });
    // Start the fade-in animation
    _animationController.forward();

  }

  @override
  void dispose() {
    _animationController.dispose(); // Dispose the controller when no longer needed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with map-like design
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/Splash_bg.png"), // Map background image
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Top-left circular shape (Red)
          Positioned(
            top: -150,
            left: -150,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 350,
              decoration: BoxDecoration(
                color: CommonStyles.primaryTextColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Top-right circular shape (Blue)
          Positioned(
            top: -200,
            right: -130,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 300,
              decoration: BoxDecoration(
                color: CommonStyles.blueColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Bottom-left circular shape (Blue)
          Positioned(
            bottom: -300,
            left: -230,
            child: Container(
              width: MediaQuery.of(context).size.width * 2,
              height: 400,
              decoration: BoxDecoration(
                color: CommonStyles.blueColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Bottom-right circular shape (Red)
          Positioned(
            bottom: -200,
            right: -150,
            child: Container(
              width: MediaQuery.of(context).size.width / 1.5,
              height: 300,
              decoration: BoxDecoration(
                color: CommonStyles.primaryTextColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Path and logo with SGT
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (BuildContext context, Widget? child) {
                    return Transform.scale(
                      scale: _animation.value,
                      child: SvgPicture.asset(
                        'assets/sgt_logo.svg',  // Use SVG logo
                        width: 150,  // Optional width
                        height: 150,  // Optional height
                      ),
                    );
                  },
                ),
                // AnimatedBuilder(
                //   animation: _animationController,
                //   builder: (BuildContext context, Widget? child) {
                //     return Transform.scale(
                //       scale: _animation.value,
                //       child: Image.asset(
                //         'assets/sgt_cis_v8_gt.png',
                //         // width: 200,
                //         // height: 200,
                //       ),
                //     );
                //   },
                // ),
                // Logo
                // Image.asset(
                //   'assets/sgt_cis_v8_gt.png',
                //  // width: 150,
                // //  fit: BoxFit.contain,
                // ),
                // Apply a slight transform to move the text up
                // Transform.translate(
                //   offset: Offset(0, -25), // Move the text 8 pixels upwards
                  TypewriterText(
                    text: "SGT",
                    color:CommonStyles.blueheader,
                  ),
            //    ),
              ],
            ),
          ),
          // Path illustration with only fade-in animation
          Positioned(
            bottom: 60, // Adjust as per your need
          left: -10,
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Image.asset(
                    'assets/Frame.png', // Path image
                    width: MediaQuery.of(context).size.width,
                    height:MediaQuery.of(context).size.height/2 ,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _requestPermissions() async {

    // Request storage permission
    Map<Permission, PermissionStatus> storageStatuses = await [
      Permission.storage,
      Permission.manageExternalStorage,
      Permission.camera
    ].request();

    var storagePermission = storageStatuses[Permission.storage];
    print('Storage permission is granted: $storagePermission');
    var manageExternalStoragePermission = storageStatuses[Permission.manageExternalStorage];
    print('Manage external storage permission is granted: $manageExternalStoragePermission');
    var status = await Permission.location.request();
    // Request location permission
  //  var status = await Permission.location.status;
    if (status.isGranted) {
      print('Foreground location permission is granted');
      // Check for background permission
      var backgroundStatus = await Permission.locationAlways.status;
      if (backgroundStatus.isGranted) {
        print('Background location permission is granted');
        // Start the background service or location tracking
      } else {
        print('Requesting background location permission');
        await Permission.locationAlways.request();
      }
    } else {
      print('Requesting foreground location permission');
      await Permission.location.request();
    }

    // Handle permissions accordingly
    if (storagePermission!.isGranted || manageExternalStoragePermission!.isGranted ) {
      // Storage permissions granted, do something
      try {
        palm3FoilDatabase = await Palm3FoilDatabase.getInstance();
        await palm3FoilDatabase!.createDatabase();
        await palm3FoilDatabase?.printTables(); // Call printTables after creating the databas
        // dbUpgradeCall();
      } catch (e) {
        print('Error while getting master data: ${e.toString()}');
      }
      startMasterSync();
    } else {
      // Storage permissions not granted, handle accordingly
      openAppSettings();
    }

    // if (locationPermission!.isGranted) {
    //   // Location permission granted, do something
    // } else {
    //   // Location permission not granted, handle accordingly
    //   openAppSettings();
    // }
  }

  Future<void> startMasterSync() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool isMasterSyncSuccess = sharedPreferences.getBool('IS_MASTER_SYNC_SUCCESS') ?? false;
    //  var connectivityResult = await Connectivity().checkConnectivity();

    if (!isMasterSyncSuccess) {
      DataSyncHelper.performMasterSync(context, isMasterSyncSuccess, (success, result, msg) {
        if (success) {
          sharedPreferences.setBool('IS_MASTER_SYNC_SUCCESS', true);
          // Implement digitalPdfSave method
          _navigateToMainLoginScreen();
        } else {
          print('Master sync failed: $msg');
          // UiUtils.showCustomToastMessage("Data syncing failed", context, 1);
     _navigateToMainLoginScreen();
        }
      });
    } else {
      //_navigateToMainLoginScreen();
    }
  }

  void _navigateToMainLoginScreen() {
    if (isLogin) {
      // Navigate to home screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ),
      );
      //  context.go(Routes.homeScreen.path);
    } else {

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ),
        );
        //     context.go(Routes.loginScreen.path);
      }
    }

  Future<void> loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLogin = prefs.getBool(Constants.isLogin) ?? false;

    });
    bool isConnected = await CommonStyles.checkInternetConnectivity();
    if (isConnected) {
      // Call your login function here

    } else {
      Fluttertoast.showToast(
          msg: "Please check your internet connection.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
      print("Please check your internet connection.");
      //showDialogMessage(context, "Please check your internet connection.");
    }
  }

  Future<void> checkLocationEnabled() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    setState(() {
      isLocationEnabled = serviceEnabled;
    });
    if (!serviceEnabled) {
      // If location services are disabled, prompt the user to enable them
      await _promptUserToEnableLocation();
    }
  }

  Future<void> _promptUserToEnableLocation() async {
    bool locationEnabled = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Location Services Disabled"),
          content: Text("Please enable location services to use this app."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text("Enable"),
            ),
          ],
        );
      },
    );

    if (locationEnabled != null && locationEnabled) {
      // Redirect the user to the device settings to enable location services
      await Geolocator.openLocationSettings();
    }
  }


// Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => LoginScreen()),
    // );
  }



class TypewriterText extends StatefulWidget {
  final String text;
  final Color color;

  const TypewriterText({
    super.key,
    required this.text,
    required this.color,
  });

  @override
  _TypewriterTextState createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  String _displayedText = ""; // Initial empty text
  int _index = 0; // Index for tracking characters

  @override
  void initState() {
    super.initState();
    // Start the typewriter animation
    _startTypewriterAnimation();
  }

  void _startTypewriterAnimation() {
    const Duration duration = Duration(milliseconds: 200);

    Timer.periodic(duration, (Timer timer) {
      if (_index < widget.text.length) {
        setState(() {
          _displayedText += widget.text[_index];
          _index++;
        });
      } else {
        // Text animation completed, cancel the timer
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text(
          _displayedText,


          style: TextStyle(
            fontSize: 28,
           color: CommonStyles.blueheader,
            fontWeight: FontWeight.w700,
           letterSpacing: 10

           // Use the provided text color
          ),
        ),
      ),
    );
  }
}




