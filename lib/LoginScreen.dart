import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'Common/Constants.dart';
import 'Forgotpassword.dart';
import 'common_styles.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'HomeScreen.dart';


import 'package:flutter/material.dart';




class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isObscure = true; // Keeps track of password visibility
  @override
  void initState() {
    super.initState();


  }

  @override
  void dispose() {

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          if (Platform.isAndroid) {
            // Close the app on Android
            SystemNavigator.pop();
            return Future.value(false); // Do not navigate back
          } else if (Platform.isIOS) {
            // Close the app on iOS
            exit(0);
            return Future.value(false); // Do not navigate back
          }
          return Future.value(true); // Default behavior (navigate back) if not Android or iOS
        },
    child:  Scaffold(

      body: Stack(
        children: [
          // Background with map-like design
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/Splash_bg.png"), // Map background image
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          // Top-left circular shape (Red)
          Positioned(
            top: -150,
            left: -200,
            child: Container(
              width: MediaQuery.of(context).size.width * 1.5,
              height: 380,
              decoration: BoxDecoration(
                color: CommonStyles.whiteColor,
                shape: BoxShape.circle,
                border:  Border.all( // Add border property here
                  color: CommonStyles.primaryTextColor, // Red border color
                  width: 2.0, // Border width
                ),
              ),

              child: Padding(
                padding: const EdgeInsets.only(left: 50.0), // Add padding to the left
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center, // Align text to start (left)
                  children: [
                    SizedBox(height: 150),
                    // App Logo
                    SvgPicture.asset(
                        "assets/sgt_v4.svg", // Replace with your actual logo path
                      width: 180, // Adjust the size of the logo
                      height: 180,
                    ),
    //                 Transform.translate(
    //                   offset: Offset(0, -25), // Move the text 8 pixels upwards
    //                   child: Text(
    // 'SGT',
    // style: TextStyle(
    // fontSize: 24,
    // fontWeight: FontWeight.bold,
    //   color:CommonStyles.blueheader, // Customize color as needed
    // ),
    //                   ),),
                  ],

              ),
            ),
          ),

          ),



          // Top-right circular shape (Blue)
          Positioned(
            top: -250,
            right: -150,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 350,
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
            right: -210,
            child: Container(
              width: MediaQuery.of(context).size.width / 1.2,
              height: 450,
              decoration: BoxDecoration(
                color: CommonStyles.primaryTextColor,
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).size.height / 2.5 - 40 ,
            left: 20,
            child: Row(
              children: [
                Icon(
                  Icons.location_pin,
                  color: CommonStyles.loginTextColor,
                  size: 30,
                ),
                SizedBox(width: 8),
                Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: CommonStyles.loginTextColor,
                  ),
                ),
              ],
            ),
          ),
    Positioned(
    top: MediaQuery.of(context).size.height / 2.5,
    left: 30,
    right: 30,
    child: Form(
    key: _formKey,
    child:
    Container(
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.6),
    borderRadius: BorderRadius.only(
    topLeft: Radius.circular(1),
    topRight: Radius.circular(20),
    bottomLeft: Radius.circular(20),
    bottomRight: Radius.circular(20),
    ),
    border: Border.all(
    color: Colors.white,
    width: 1,
    ),
    ),
    child:
    Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    SizedBox(height: 15),
    // Mobile Number / Email TextField
    TextFormField(
    controller: _usernameController,
    decoration: InputDecoration(
    labelText: "Mobile Number/Email/User Name *",
    hintText: "Enter Mobile Number/Email/User Name",
    border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    ),
    ),
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Please Enter a Mobile Number/Email/User Name';
    }
    return null;
    },
    ),
    SizedBox(height: 10),
    // Password TextField
    TextFormField(
    controller: _passwordController,
    obscureText: _isObscure, // Toggle between true and false
    decoration: InputDecoration(
    labelText: "Password *",
    hintText: "Enter Password ",
    border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    ),
    suffixIcon: IconButton(
    icon: Icon(
    _isObscure ? Icons.visibility_off : Icons.visibility, // Icon changes based on visibility
    ),
    onPressed: () {
    setState(() {
    _isObscure = !_isObscure; // Toggle password visibility
    });
    },
    ),
    ),
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Please Enter a Password';
    }
    return null;
    },
    ),
    Align(
    alignment: Alignment.centerRight,
    child: TextButton(
    onPressed: () {
    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => Forgotpassword()),
    );
    },
    child: Text(
    "Forgot Password?",
    style: TextStyle(color: CommonStyles.blueheader),
    ),
    ),
    ),
    // Login Button
    SizedBox(
    width: double.infinity,
    height: 45,
    child: ElevatedButton(
    onPressed: _login,
    style: ElevatedButton.styleFrom(
    padding: EdgeInsets.symmetric(vertical: 10),
    backgroundColor: CommonStyles.buttonbg,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
    ),
    ),
    child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Icon(
    Icons.perm_identity,
    color: CommonStyles.whiteColor,
    size: 20,
    ),
    SizedBox(width: 10),
    Text(
    "Login",
    style: TextStyle(
    fontSize: 18,
    color: Colors.white,
    ),
    ),
    ],
    ),
    ),
    ),
    ],
    ),
    ),
    ),
    )


        ],
      ),
    ));
  }

  Future<void> _login() async {
    bool isConnected = await CommonStyles.checkInternetConnectivity();
    if (isConnected) {
      if (_formKey.currentState!.validate()) {
        String username = _usernameController.text.trim();
        String password = _passwordController.text.trim();

        // API URL
        String url = 'http://182.18.157.215/SmartGeoTrack/API/User/ValidateUser';
        print('url=== ${url}');
        // Request body
        Map<String, String> body = {
          'username': username,
          'password': password,
        };

        try {
          // Send HTTP POST request
          final response = await http.post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          );
          print('object ${json.encode(body)}');
          if (response.statusCode == 200) {
            final data = json.decode(response.body);

            if (data['issucces']) {
              // Successful login
              // Navigate to the Home screen
              SharedPreferences prefs = await SharedPreferences.getInstance();

              // Save the user data in SharedPreferences
              prefs.setBool(Constants.isLogin, true);
              prefs.setString('token', data['token']);
              prefs.setInt('userID', data['user']['id']);
              prefs.setString('username', data['user']['username']);
              prefs.setString('firstName', data['user']['firstName']);
              prefs.setString('email', data['user']['email']);
              prefs.setString('mobileNumber', data['user']['mobileNumber']);
              prefs.setInt('roleID', data['user']['roleID']);
              prefs.setString('roleName', data['user']['roleName']);

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            } else {
              // Show error message
              _showErrorDialog("Login failed: Invalid username or password.");
            }
          } else {
            _showErrorDialog("Error: ${response.statusCode}");
          }
        } catch (e) {
          _showErrorDialog("An error occurred: $e");
        }
      }
    }
   else
     {
       Fluttertoast.showToast(
           msg: "Please check your internet connection.",
           toastLength: Toast.LENGTH_SHORT,
           gravity: ToastGravity.CENTER,
           timeInSecForIosWeb: 1,
           backgroundColor: Colors.red,
           textColor: Colors.white,
           fontSize: 16.0
       );
     }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }
}




