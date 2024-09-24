import 'package:flutter/material.dart';
import 'dart:async';

import 'package:smartgetrack/LoginScreen.dart';

import 'package:flutter/material.dart';
import 'dart:async';

class PasswordChangedScreen extends StatefulWidget {
  @override
  _PasswordChangedScreenState createState() => _PasswordChangedScreenState();
}

class _PasswordChangedScreenState extends State<PasswordChangedScreen> {
  @override
  void initState() {
    super.initState();
    // Redirect to login screen after 10 seconds
    Timer(Duration(seconds: 10), () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    //   Navigator.of(context).pushReplacementNamed('/login'); // Change '/login' to your login route
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );

          return Future.value(true); // Default behavior (navigate back) if not Android or iOS
        },
    child:  Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // GIF image from assets
              Container(
                child: Image.asset(
                  'assets/Rectangle.png',
                  width: 150.0,
                  height: 150.0,
                ),
              ),
              const SizedBox(height: 30.0),
              // Title
              Text(
                'Password Changed Successfully',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10.0),
              // Subtitle message
              Text(
                'You have successfully changed your password, it will redirect to login screen in 10 sec.',
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    ));
  }
}
