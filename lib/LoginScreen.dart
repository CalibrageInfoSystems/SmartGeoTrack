import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'CommonUtils.dart';
import 'CustomButton.dart';
import 'CustomeFormField.dart';
import 'HomeScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => userLoginState();
}

class userLoginState extends State<LoginScreen> {
  bool isTextFieldFocused = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _emailError = false;
  bool _passwordError = false;
  String? invalidCredentials;
  String? _emailErrorMsg;
  String? _passwordErrorMsg;
  bool showPassword = true;
  bool validateUserEmail = false;
  bool validateUserPassword = false;
  String firebaseToken = "";

  String notificationMsg = "Waiting for notifications";
  @override
  void initState() {
    super.initState();


  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {

          return true;
        },
        child: Scaffold(
          backgroundColor: CommonUtils.primaryColor,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: CommonUtils.primaryTextColor,
              ),
              onPressed: () {
                // Navigator.of(
                //   context,
                // ).pop();

                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (context) => startingscreen(),
                //     ));
              },
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height / 2.2,
                  decoration: const BoxDecoration(),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.height / 4.5,
                          child: Image.asset('assets/hfz_logo.png'),
                        ),
                        const SizedBox(
                          height: 5.0,
                        ),
                        const Text('Login',
                            style: TextStyle(
                              fontSize: 24,
                              fontFamily: "Outfit",
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2,
                              color: Color(0xFF11528f),
                            )),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height - MediaQuery.of(context).size.height / 2,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Form(
                      key: _formKey,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30.0),
                            topRight: Radius.circular(30.0),
                          ),
                        ),
                        height: MediaQuery.of(context).size.height / 2,
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                CustomeFormField(
                                  label: 'Email / User Name',
                                  errorText: _emailError ? _emailErrorMsg : null,
                                  onChanged: (_) {
                                    setState(() {
                                      _emailError = false;
                                    });
                                  },
                                  validator: validateEmail,
                                  controller: _emailController,
                                  maxLength: 60,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                CustomeFormField(
                                  label: 'Password',
                                  errorText: _passwordError ? _passwordErrorMsg : null,
                                  onChanged: (_) {
                                    setState(() {
                                      _passwordError = false;
                                    });
                                  },
                                  validator: validatePassword,
                                  controller: _passwordController,
                                  maxLength: 25,
                                  obscureText: showPassword,
                                  suffixIcon: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        showPassword = !showPassword;
                                      });
                                    },
                                    child: Icon(showPassword ? Icons.visibility_off : Icons.visibility),
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                // Row(
                                //   mainAxisAlignment: MainAxisAlignment.end,
                                //   children: [
                                //     GestureDetector(
                                //       onTap: () {
                                //         Navigator.push(
                                //           context,
                                //           MaterialPageRoute(
                                //               builder: (context) =>
                                //                   const ForgotPasswordscreen()),
                                //         );
                                //       },
                                //       child: const Text(
                                //         'Forgot Password?',
                                //         style: CommonUtils.Mediumtext_o_14,
                                //       ),
                                //     ),
                                //   ],
                                // ),
                                const SizedBox(
                                  height: 30,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: CustomButton(
                                        buttonText: 'Login',
                                        color: CommonUtils.primaryTextColor,
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => HomeScreen(),
                                              ));
                                          // if (_formKey.currentState!.validate()) {
                                          //   if (validateUserEmail && validateUserPassword) {
                                          //     _handleLogin();
                                          //   }
                                          // }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 30,
                                ),

                                // Row(
                                //   mainAxisAlignment: MainAxisAlignment.center,
                                //   children: [
                                //     const Text('New User?',
                                //         style: CommonUtils.Mediumtext_14),
                                //     const SizedBox(width: 8.0),
                                //     GestureDetector(
                                //       onTap: () {

                                //         print('Click here! clicked');

                                //         Navigator.of(context).push(
                                //           MaterialPageRoute(
                                //             builder: (context) =>
                                //                 const CustomerRegisterScreen(),
                                //           ),
                                //         );
                                //       },
                                //       child: const Text(
                                //         'Register Here!',
                                //         style: TextStyle(
                                //           fontSize: 20,
                                //           fontFamily: "Outfit",
                                //           fontWeight: FontWeight.w700,
                                //           color: Color(0xFF0f75bc),
                                //         ),
                                //       ),
                                //     ),
                                //   ],
                                // ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  String? validateEmail(String? value) {
    if (value!.isEmpty) {
      setState(() {
        _emailError = true;
        _emailErrorMsg = 'Please Enter Email / User Name';
      });
      return null;
    }

    if (invalidCredentials != null) {
      setState(() {
        invalidCredentials = null;
      });
      return null;
    }
    validateUserEmail = true;
    return null;
  }

  String? validatePassword(String? value) {
    if (value!.isEmpty) {
      setState(() {
        _passwordError = true;
        _passwordErrorMsg = 'Please Enter Password';
      });
      return null;
    }

    if (invalidCredentials != null) {
      setState(() {
        invalidCredentials = null;
      });
      return null;
    }

    validateUserPassword = true;
    return null;
  }

  String? endUserMessageFromApi(int code, String endUserMessage) {
    if (code == 10) {
      setState(() {
        _emailError = true;
        _emailErrorMsg = endUserMessage;
        _passwordError = true;
        _passwordErrorMsg = endUserMessage;

        validateUserEmail = false;
        validateUserPassword = false;
      });
    }

    return null;
  }

  Future<void> _handleLogin() async {
    String username = _emailController.text;
    String password = _passwordController.text;
    bool isValid = true;
    bool hasValidationFailed = false;
    if (username.isEmpty) {
      CommonUtils.showCustomToastMessageLong('Please Enter Username', context, 1, 4);
      isValid = false;
      hasValidationFailed = true;
      // Hide the keyboard || password.isEmpty
      FocusScope.of(context).unfocus();
    } else if (password.isEmpty) {
      CommonUtils.showCustomToastMessageLong('Please Enter Password', context, 1, 4);
      isValid = false;
      hasValidationFailed = true;
      // Hide the keyboard || password.isEmpty
      FocusScope.of(context).unfocus();
    } else {
      bool isConnected = await CommonUtils.checkInternetConnectivity();
      if (isConnected) {
        print('Connected to the internet');
        FocusScope.of(context).unfocus();
        login(username, password);
      } else {
        CommonUtils.showCustomToastMessageLong('Please Check Your Internet Connection', context, 1, 4);
        FocusScope.of(context).unfocus();
        print('Not connected to the internet');
      }
    }
  }

  Future<void> login(String usename, String password) async {


  }

  Future<void> addAgentSlotInformation(Map<String, dynamic> agentSlotsDetailsMap, int agentId) async {


  }

  Future<void> saveUserDataToSharedPreferences(Map<String, dynamic> userData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setInt('userId', userData['id']);
    prefs.setBool('isLoggedIn', true);
    await prefs.setString('userFullName', userData['firstName']);
    await prefs.setInt('userRoleId', userData['roleID']);
    await prefs.setString('email', userData['email']);
    await prefs.setString('contactNumber', userData['contactNumber']);
    await prefs.setString('gender', userData['gender']);
  }




}
