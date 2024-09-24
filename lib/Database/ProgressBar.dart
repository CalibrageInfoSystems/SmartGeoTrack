import 'package:flutter/material.dart';

class ProgressBar {
  static void showProgressBar(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text(message),
              ],
            ),
          ),
        );
      },
    );
  }

  static void hideProgressBar(BuildContext context) {
    Navigator.pop(context);
  }
}
