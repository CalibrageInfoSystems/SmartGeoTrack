//
// import 'dart:convert';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:smartgetrack/LoginScreen.dart';
//
// import 'CommonUtils.dart';
// import 'CustomButton.dart';
// import 'common_styles.dart';
//
// class Changepassword extends StatefulWidget {
//   final int id;
//   final String password;
//
//   Changepassword({required this.id, required this.password});
//
//   @override
//   State<Changepassword> createState() => _ChangePasswordScreenState();
// }
//
// class _ChangePasswordScreenState extends State<Changepassword> {
//   final TextEditingController _currentController = TextEditingController();
//   final TextEditingController _newController = TextEditingController();
//   final TextEditingController _confirmNewController = TextEditingController();
//   bool showPassword = true;
//   bool newshowPassword = true;
//   bool confirmshowPassword = true;
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//
//   @override
//   void dispose() {
//     _currentController.dispose();
//     _newController.dispose();
//     _confirmNewController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: _appBar(context),
//         body:  Container(
//           color: Colors.white,
//           child:SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: Container(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     const SizedBox(
//                       height: 30,
//                     ),
//                     SizedBox(
//                       width: MediaQuery.of(context).size.height / 5,
//                       child: Image.asset('assets/hfz_logo.png'),
//                     ),
//                     const SizedBox(
//                       height: 120,
//                     ),
//                     Form(
//                       key: _formKey,
//                       child: Column(
//                         children: [
//                           // CustomeFormField(
//                           //   label: 'Current Password',
//                           //   validator: validateCurrentPassword,
//                           //   controller: _currentController,
//                           // ),
//                           // SizedBox(
//                           //   height: 10,
//                           // ),
//                           // CustomeFormField(
//                           //   label: 'New Password',
//                           //   validator: validateNewPassword,
//                           //   controller: _newController,
//                           // ),
//                           // const SizedBox(
//                           //   height: 10,
//                           // ),
//                           // CustomeFormField(
//                           //   label: 'Confirm New Password',
//                           //   validator: validateConfirmNewPassword,
//                           //   controller: _confirmNewController,
//                           // ),
//                           Row(
//                             children: [
//                               Text(
//                                 'Current Password ',
//                                 style: CommonStyles.txSty_12b_f5,
//                               ),
//                               Text(
//                                 ' *',
//                                 style: TextStyle(color: Colors.red),
//                               ),
//                             ],
//                           ),
//                           SizedBox(
//                             height: 5,
//                           ),
//                           TextFormField(
//                             controller: _currentController,
//                             keyboardType: TextInputType.visiblePassword,
//                             obscureText: showPassword,
//                             maxLength: 25,
//                             maxLengthEnforcement: MaxLengthEnforcement.enforced,
//                             decoration: InputDecoration(
//                               //errorText: _passwordError ? _passwordErrorMsg : null,
//                                 suffixIcon: GestureDetector(
//                                   onTap: () {
//                                     setState(() {
//                                       showPassword = !showPassword;
//                                     });
//                                   },
//                                   child: Icon(showPassword ? Icons.visibility_off : Icons.visibility),
//                                 ),
//                                 contentPadding: const EdgeInsets.only(top: 15, bottom: 10, left: 15, right: 15),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderSide: const BorderSide(
//                                     color: Color(0xFF0f75bc),
//                                   ),
//                                   borderRadius: BorderRadius.circular(6.0),
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderSide: const BorderSide(
//                                     color: CommonUtils.primaryTextColor,
//                                   ),
//                                   borderRadius: BorderRadius.circular(6.0),
//                                 ),
//                                 border: const OutlineInputBorder(
//                                   borderRadius: BorderRadius.all(
//                                     Radius.circular(10),
//                                   ),
//                                 ),
//                                 hintText: 'Enter Current Password',
//                                 counterText: "",
//                                 hintStyle: CommonStyles.texthintstyle
//                             ),
//                             validator: validateCurrentPassword,
//                             inputFormatters: [
//                               FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9!@#$%^&*(),.?":{}|<>_-]')),
//                             ],
//                             onChanged: (value) {
//                               setState(() {
//                                 if (value.startsWith(' ')) {
//                                   _currentController.value = TextEditingValue(
//                                     text: value.trimLeft(),
//                                     selection: TextSelection.collapsed(offset: value.trimLeft().length),
//                                   );
//                                   return;
//                                 }
//                                 // _passwordError = false;
//                                 // isPasswordValidate = true;
//                                 // if (isPasswordValidate) {
//                                 //   _updatePasswordStrengthMessage(value);
//                                 // }
//                               });
//                             },
//                           ),
//                           SizedBox(
//                             height: 10,
//                           ),
//                           Row(
//                             children: [
//                               Text(
//                                 'New Password ',
//                                 style: CommonStyles.txSty_12b_f5,
//                               ),
//                               Text(
//                                 ' *',
//                                 style: TextStyle(color: Colors.red),
//                               ),
//                             ],
//                           ),
//                           SizedBox(
//                             height: 5,
//                           ),
//                           TextFormField(
//                             controller: _newController,
//                             keyboardType: TextInputType.visiblePassword,
//                             obscureText: newshowPassword,
//                             maxLength: 25,
//                             maxLengthEnforcement: MaxLengthEnforcement.enforced,
//                             decoration: InputDecoration(
//                               errorMaxLines: 5,
//                               //errorText: _passwordError ? _passwordErrorMsg : null,
//                               suffixIcon: GestureDetector(
//                                 onTap: () {
//                                   setState(() {
//                                     newshowPassword = !newshowPassword;
//                                   });
//                                 },
//                                 child: Icon(newshowPassword ? Icons.visibility_off : Icons.visibility),
//                               ),
//                               contentPadding: const EdgeInsets.only(top: 15, bottom: 10, left: 15, right: 15),
//                               focusedBorder: OutlineInputBorder(
//                                 borderSide: const BorderSide(
//                                   color: Color(0xFF0f75bc),
//                                 ),
//                                 borderRadius: BorderRadius.circular(6.0),
//                               ),
//                               enabledBorder: OutlineInputBorder(
//                                 borderSide: const BorderSide(
//                                   color: CommonUtils.primaryTextColor,
//                                 ),
//                                 borderRadius: BorderRadius.circular(6.0),
//                               ),
//                               border: const OutlineInputBorder(
//                                 borderRadius: BorderRadius.all(
//                                   Radius.circular(10),
//                                 ),
//                               ),
//                               hintText: 'Enter New Password',
//                               counterText: "",
//                               hintStyle: CommonStyles.texthintstyle,
//                             ),
//                             validator: validateNewPassword,
//                             inputFormatters: [
//                               FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9!@#$%^&*(),.?":{}|<>_-]')),
//                             ],
//                             onChanged: (value) {
//                               setState(() {
//                                 if (value.startsWith(' ')) {
//                                   _newController.value = TextEditingValue(
//                                     text: value.trimLeft(),
//                                     selection: TextSelection.collapsed(offset: value.trimLeft().length),
//                                   );
//                                   return;
//                                 }
//                                 // _passwordError = false;
//                                 // isPasswordValidate = true;
//                                 // if (isPasswordValidate) {
//                                 //   _updatePasswordStrengthMessage(value);
//                                 // }
//                               });
//                             },
//                           ),
//                           SizedBox(
//                             height: 10,
//                           ),
//                           Row(
//                             children: [
//                               Text(
//                                 'Confirm  Password ',
//                                 style: CommonStyles.txSty_12b_f5,
//                               ),
//                               Text(
//                                 ' *',
//                                 style: TextStyle(color: Colors.red),
//                               ),
//                             ],
//                           ),
//                           SizedBox(
//                             height: 5,
//                           ),
//                           TextFormField(
//                             controller: _confirmNewController,
//                             keyboardType: TextInputType.visiblePassword,
//                             obscureText: confirmshowPassword,
//                             maxLength: 25,
//                             maxLengthEnforcement: MaxLengthEnforcement.enforced,
//                             decoration: InputDecoration(
//                               //errorText: _passwordError ? _passwordErrorMsg : null,
//                                 suffixIcon: GestureDetector(
//                                   onTap: () {
//                                     setState(() {
//                                       confirmshowPassword = !confirmshowPassword;
//                                     });
//                                   },
//                                   child: Icon(confirmshowPassword ? Icons.visibility_off : Icons.visibility),
//                                 ),
//                                 contentPadding: const EdgeInsets.only(top: 15, bottom: 10, left: 15, right: 15),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderSide: const BorderSide(
//                                     color: Color(0xFF0f75bc),
//                                   ),
//                                   borderRadius: BorderRadius.circular(6.0),
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderSide: const BorderSide(
//                                     color: CommonUtils.primaryTextColor,
//                                   ),
//                                   borderRadius: BorderRadius.circular(6.0),
//                                 ),
//                                 border: const OutlineInputBorder(
//                                   borderRadius: BorderRadius.all(
//                                     Radius.circular(10),
//                                   ),
//                                 ),
//                                 hintText: 'Enter Confirm Password',
//                                 counterText: "",
//                                 hintStyle: CommonStyles.texthintstyle
//                             ),
//                             validator: validateConfirmNewPassword,
//                             inputFormatters: [
//                               FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9!@#$%^&*(),.?":{}|<>_-]')),
//                             ],
//                             onChanged: (value) {
//                               setState(() {
//                                 if (value.startsWith(' ')) {
//                                   _confirmNewController.value = TextEditingValue(
//                                     text: value.trimLeft(),
//                                     selection: TextSelection.collapsed(offset: value.trimLeft().length),
//                                   );
//                                   return;
//                                 }
//                                 // _passwordError = false;
//                                 // isPasswordValidate = true;
//                                 // if (isPasswordValidate) {
//                                 //   _updatePasswordStrengthMessage(value);
//                                 // }
//                               });
//                             },
//                           ),
//
//                           const SizedBox(
//                             height: 60,
//                           ),
//                           //MARK: Update Button
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: CustomButton(
//                                   buttonText: 'Update Password',
//                                   color: CommonUtils.primaryTextColor,
//                                   onPressed: changePassword,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ));
//   }
//
//   Future<void> changePassword() async {
//     if (_formKey.currentState!.validate()) {
//       String? currentpassword = _currentController.text;
//       String? newpassword = _newController.text;
//       String? confirmnewpassword = _confirmNewController.text;
//       // Print the username and password
//       int id = widget.id;
//       // CommonStyles.progressBar(context);
//    //   ProgressDialog progressDialog = ProgressDialog(context);
//
//       // Show the progress dialog
//   //    progressDialog.show();
//     //  final String apiUrl = baseUrl + changepassword;
//
//       // Prepare the request body
//       Map<String, dynamic> requestBody = {
//         "id": id.toInt(),
//         "oldPassword": "$currentpassword",
//         "newPassword": "$newpassword",
//         "confirmPassword": "$confirmnewpassword"
//       };
//       print('requestBody${json.encode(requestBody)}');
//       // Make the POST request
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         body: json.encode(requestBody),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//       );
//       Map<String, dynamic> data = json.decode(response.body);
//
//       if (response.statusCode == 200) {
//         // Parse the JSON response
//         Map<String, dynamic> data = json.decode(response.body);
//
//         // Check the value of "isSuccess" in the JSON data
//         bool isSuccess = data["isSuccess"];
//
//         // Extract the status message from the JSON data
//         String statusMessage = data["statusMessage"];
//
//         // Show the appropriate toast message based on "isSuccess"
//         if (isSuccess) {
//           // Success case: show the success message
//           progressDialog.dismiss();
//           onConfirmLogout(context);
//           // Navigator.of(context).push(
//           //   MaterialPageRoute(
//           //     builder: (context) => HomeScreen(),
//           //   ),
//           // );
//           CommonUtils.showCustomToastMessageLong('$statusMessage', context, 0, 5, toastPosition: MediaQuery.of(context).size.height / 2);
//         } else {
//           progressDialog.dismiss();
//           // Failure case: show the status message
//           CommonUtils.showCustomToastMessageLong('$statusMessage', context, 1, 5, toastPosition: MediaQuery.of(context).size.height / 2);
//         }
//       } else {
//         FocusScope.of(context).unfocus();
//         CommonUtils.showCustomToastMessageLong('${data["statusMessage"]} ', context, 1, 5, toastPosition: MediaQuery.of(context).size.height / 2);
//         setState(() {
//           progressDialog.dismiss();
//         });
//         // Handle any error cases here
//         print('Failed to connect to the API. Status code: ${response.statusCode}');
//       }
//     }
//   }
//
//   // String? validateCurrentPassword(String? value) {
//   //   if (value == null || value.isEmpty) {
//   //     return 'Please Enter Current Password';
//   //   }
//   //   return null;
//   // }
//   String? validateCurrentPassword(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Please Enter Current Password';
//     }
//     if (value != widget.password) {
//       return 'Invalid Current Password';
//     }
//     return null;
//   }
//
//   // String? validateNewPassword(String? value) {
//   //   if (value == null || value.isEmpty) {
//   //     return 'Please Enter New Password';
//   //   }
//   //   if (_newController.text == _currentController.text) {
//   //     return 'New Password Cannot Be The Same As The Current Password';
//   //   }
//   //   return null;
//   // }
//   String? validateNewPassword(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Please Enter New Password';
//     }
//     if (_newController.text == _currentController.text) {
//       return 'New Password Cannot Be The Same As The Current Password';
//     }
//
//     final passwordRegex = RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>])(?=.*[A-Z]).{8,}$');
//     if (!passwordRegex.hasMatch(value)) {
//       return 'Password Must Include One Uppercase, One Lowercase, One Digit, One Special Character, No Spaces, And be 08-25 Characters Long';
//     }
//
//     // Additional custom validations can be added here
//
//     return null; // Password is valid
//   }
//
//   String? validateConfirmNewPassword(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Please Enter Confirm Password';
//     }
//     if (_newController.text != _confirmNewController.text) {
//       return 'Confirm Password Must Be Same As New Password';
//     }
//     return null;
//   }
//   // New Password Cannot Be The Same As The Current Password
//
//   AppBar _appBar(BuildContext context) {
//     return AppBar(
//         elevation: 0,
//         backgroundColor: const Color(0xffe2f0fd),
//         title: const Text(
//           'Change Password',
//           style: TextStyle(color: Color(0xFF0f75bc), fontSize: 16.0),
//         ),
//         titleSpacing:0.0,
//         actions: [
//           IconButton(
//             icon: SvgPicture.asset(
//               'assets/sign-out-alt.svg', // Path to your SVG asset
//               color: const Color(0xFF662e91),
//               width: 24, // Adjust width as needed
//               height: 24, // Adjust height as needed
//             ),
//             onPressed: () {
//               logOutDialog(context);
//               // Add logout functionality here
//             },
//           ),
//         ],
//         // centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(
//             Icons.arrow_back_ios,
//             color: CommonUtils.primaryTextColor,
//           ),
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//         ));
//   }
//
//   void logOutDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Logout',style: CommonStyles.txSty_18b_fb,),
//           content: const Text('Are You Sure You Want to Logout?',style: CommonStyles.txSty_16b_fb),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('No'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 onConfirmLogout(context);
//               },
//               child: const Text('Yes'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Future<void>    onConfirmLogout(BuildContext context) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     prefs.setBool('isLoggedIn', false);
//     prefs.remove('userId'); // Remove userId from SharedPreferences
//     prefs.remove('userRoleId'); // Remove roleId from SharedPreferences
//     CommonUtils.showCustomToastMessageLong("Logout Successful", context, 0, 3);
//
//     Navigator.of(context).pushAndRemoveUntil(
//       MaterialPageRoute(builder: (context) => LoginScreen()),
//           (route) => false,
//     );
//   }
// }
