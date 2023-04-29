import 'package:flutter/material.dart';
import 'package:talbna/app_theme.dart';

class TextFromField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;
  final Function validator;
  final Widget prefixIcon;
  final Icon? suffixIcon;
  final String hintText;
  final EdgeInsets padding;
  const TextFromField(
      {Key? key,
      required this.controller,
      required this.obscureText,
      required this.validator,
      required this.prefixIcon,
      required this.hintText,
       this.suffixIcon,
      required TextInputType keyboardType, required this.padding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: SizedBox(
        child: TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: TextInputType.text,
          validator: (value) => validator(value),
          decoration: InputDecoration(
            prefixIcon: prefixIcon,
            prefixIconColor: AppTheme.primaryColor,
            suffixIconColor: AppTheme.primaryColor,
            suffixIcon: suffixIcon,
            hintText: hintText,
            filled: true,
            enabledBorder: OutlineInputBorder(
              borderSide:  const BorderSide(
                color: AppTheme.primaryColor,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Colors.teal,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Colors.red,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Colors.red,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}
