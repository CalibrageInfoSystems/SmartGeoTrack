import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smartgetrack/common_styles.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextInputType keyboardType;
  final int? maxLength;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final bool obscureText;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final String? errorText;
  final void Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final bool readOnly; // Add the readOnly parameter
  final TextStyle? errorStyle;
  final TextStyle? textStyle;
  const CustomTextField({
    super.key,
    required this.label,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.maxLengthEnforcement,
    this.obscureText = false,
    this.suffixIcon,
    this.onTap,
    this.errorText,
    this.onChanged,
    this.inputFormatters,
    this.validator,
    this.controller,
    this.readOnly = false,
    this.errorStyle,
    this.textStyle, // Initialize the readOnly parameter with a default value
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,

      decoration: InputDecoration(
        suffixIcon: suffixIcon,
        contentPadding:
            const EdgeInsets.only(top: 15, bottom: 10, left: 15, right: 15),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: CommonStyles.btnBlueBgColor,
          ),
          borderRadius: BorderRadius.circular(6.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: CommonStyles.btnBlueBgColor,
          ),
          borderRadius: BorderRadius.circular(6.0),
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: CommonStyles.btnBlueBgColor,
          ),
          borderRadius: BorderRadius.circular(6.0),
        ),
        hintText: 'Select $label',
        hintStyle: CommonStyles.texthintstyle,
        label: Text(
          '$label ',
          style: CommonStyles.txStyF14CbFF5,
        ),
        errorText: errorText,
        errorStyle: CommonStyles.texthintstyle.copyWith(
          color: const Color.fromARGB(255, 175, 15, 4),
        ),
        counterText: "",
      ),
      inputFormatters: inputFormatters,
      validator: validator,
      onChanged: onChanged,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLength: maxLength,
      maxLengthEnforcement: maxLengthEnforcement,
      readOnly: readOnly, // Pass the readOnly parameter to the TextFormField
      onTap: onTap,
      style: CommonStyles.txSty_14b_fb,
      //  textStyle :CommonStyles.txSty_14b_fb
      // Add onTap to handle any additional logic if needed
    );
  }
}


//const EdgeInsets.symmetric(horizontal: 10, vertical: 5)
// .copyWith(top: 5),
