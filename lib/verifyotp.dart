import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Forgotpassword.dart';
import 'NewPassword.dart';
import 'common_styles.dart';
import 'package:http/http.dart' as http;

class verifyotp extends StatefulWidget {
  final String username;

  const verifyotp({super.key, required this.username});

  @override
  _verifyotpScreenState createState() => _verifyotpScreenState();
}

class _verifyotpScreenState extends State<verifyotp>
    with SingleTickerProviderStateMixin {
 // final _formKey = GlobalKey<FormState>();
  final TextEditingController _otpController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Declare the form key

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          backgroundColor: Colors.transparent,
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with map-like design
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      "assets/Splash_bg.png"), // Map background image
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
                border: Border.all(
                  // Add border property here
                  color: CommonStyles.primaryTextColor, // Red border color
                  width: 2.0, // Border width
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 50.0), // Add padding to the left
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // Align text to start (left)
                  children: [
                    const SizedBox(height: 150),
                    // App Logo
                    Image.asset(
                      'assets/login_App_logo.png', // Replace with your actual logo path
                      // width: 100, // Adjust the size of the logo
                      // height: 100,
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
              decoration: const BoxDecoration(
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
              decoration: const BoxDecoration(
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
              decoration: const BoxDecoration(
                color: CommonStyles.primaryTextColor,
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).size.height / 2.5 - 40,
            left: 20,
            child: const Row(
              children: [
                Icon(
                  Icons.location_pin,
                  color: CommonStyles.loginTextColor,
                  size: 30,
                ),
                SizedBox(width: 8),
                Text(
                  "Forgot Password",
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
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: const BorderRadius.only(
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
              child: Form( // Wrap with Form widget
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),
                    // OTP TextField
                    TextFormField(
                      controller: _otpController,
                      decoration: InputDecoration(
                        labelText: "OTP *",
                        hintText: "Enter OTP",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter OTP';
                        } else if (value.length != 6) {
                          return 'OTP must be 6 digits';
                        } else if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                          return 'Only digits allowed';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    // Resend OTP Button
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: resendotpmethod,
                        child: const Text(
                          "Resend OTP?",
                          style: TextStyle(color: CommonStyles.blueheader),
                        ),
                      ),
                    ),
                    // Verify OTP Button
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _validateOtp(); // Call OTP validation if form is valid
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          backgroundColor: CommonStyles.buttonbg,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Verify OTP",
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
          ),
        ],
      ),
    );
  }



  void _validateOtp() async {
    if (_formKey.currentState!.validate()) {
      showLoadingDialog(context);
      String otp = _otpController.text;
      var url =
      Uri.parse('http://182.18.157.215/SmartGeoTrack/API/Login/ValidOTP');

      // Prepare the request body
      var body = json.encode({
        "otp": otp,
        "userName": widget.username,
      });

      // Make the POST request
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );
      Navigator.of(context).pop();
      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        // Check if API was successful
        if (data['isSuccess']) {
          // Extract userId and userName from the response
          var listResult = data['listResult'];
          if (listResult.isNotEmpty) {
            int userId = listResult[0]['userId'];
            String userName = listResult[0]['userName'];

            // Navigate to NewPassword screen with userId and userName
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    NewPassword(id: userId, username: userName),
              ),
            );
          }
        } else {
          // Show error message if OTP is invalid
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['endUserMessage'] ?? 'Invalid OTP')),
          );
        }
      } else {
        // Handle error when API call fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('API Error: ${response.statusCode}')),
        );
      }
    }
  }
  void resendotpmethod() async {
    var url =
        Uri.parse('http://182.18.157.215/SmartGeoTrack/API/Login/GetUserOTP');

    // Prepare the request body
    var body = json.encode({
      "userName": widget.username,
    });

    // Make the POST request
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      // Check if API was successful
      if (data['isSuccess']) {
        // No need to access listResult as it is empty in this case
        // Just navigate to the OTP screen directly
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Otp sent to your Email')),
        );
      } else {
        // Show error message if API fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['endUserMessage'] ?? 'Invalid username')),
        );
      }
    } else {
      // Handle error when API call fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('API Error: ${response.statusCode}')),
      );
    }
  }
}
