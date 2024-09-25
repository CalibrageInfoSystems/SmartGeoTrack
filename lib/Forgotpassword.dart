import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smartgetrack/verifyotp.dart';
import 'NewPassword.dart';
import 'common_styles.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Forgotpassword extends StatefulWidget {
  const Forgotpassword({super.key});

  @override
  _ForgotpasswordScreenState createState() => _ForgotpasswordScreenState();
}

class _ForgotpasswordScreenState extends State<Forgotpassword>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

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
                    SvgPicture.asset(
                      "assets/sgt_v4.svg", // Replace with your actual logo path
                      width: 180, // Adjust the size of the logo
                      height: 180,
                    ),
                    // Image.asset(
                    //   'assets/login_App_logo.png', // Replace with your actual logo path
                    //   // width: 100, // Adjust the size of the logo
                    //   // height: 100,
                    // ),
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
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),
                    // Username TextField
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: "Mobile Number/Email/User Name * ",
                        hintText: "Enter Mobile Number/Email/User Name ",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please Enter Your Mobile Number/Email/User Name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          backgroundColor: CommonStyles.buttonbg,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Send OTP",
                          style: TextStyle(fontSize: 18, color: Colors.white),
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

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      // Call the API
      showLoadingDialog(context);
      String username = _usernameController.text;
      var url =
          Uri.parse('http://182.18.157.215/SmartGeoTrack/API/Login/GetUserOTP');

      // Prepare the request body
      var body = json.encode({"userName": username});

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
          // No need to access listResult as it is empty in this case
          // Just navigate to the OTP screen directly
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => verifyotp(
                  username: username), // Adjust with your OTP screen widget
            ),
          );
        } else {
          // Show error message if API fails
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(data['endUserMessage'] ?? 'Invalid username')),
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
  // void _submit() async {
  //   if (_formKey.currentState!.validate()) {
  //     // Call the API
  //     String username = _usernameController.text;
  //     var url = Uri.parse('http://182.18.157.215/SmartGeoTrack/API/Login/GetUserOTP');
  //
  //     // Make the POST request
  //     var response = await http.post(url);
  //     if (response.statusCode == 200) {
  //       var data = json.decode(response.body);
  //
  //       // Check if API was successful
  //       if (data['isSuccess']) {
  //         var listResult = data['listResult'][0];
  //         int id = listResult['id'];
  //         String username = listResult['username'];
  //
  //         // Navigate to the next screen with id and username
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => verifyotp(id: id, username: username),
  //           ),
  //         );
  //       } else {
  //         // Show error message if API fails
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text('Invalid username')),
  //         );
  //       }
  //     } else {
  //       // Handle error when API call fails
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('API Error: ${response.statusCode}')),
  //       );
  //     }
  //   }
  // }
}
