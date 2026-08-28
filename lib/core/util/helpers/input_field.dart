import 'package:flutter/material.dart';

Widget field(
  TextEditingController controller,
  String label,
  IconData icon,
  TextInputType? keyboardType,
  String? Function(String?) validator, {
  bool obscureText = false,
  Widget? suffix,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    obscureText: obscureText,
    validator: validator,
    textInputAction: TextInputAction.next,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
    ),
  );
}
