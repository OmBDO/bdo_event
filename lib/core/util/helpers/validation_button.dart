import 'package:flutter/material.dart';

Widget visibilityButton(bool visible, VoidCallback onPressed) {
  return IconButton(
    tooltip: visible ? 'Hide password' : 'Show password',
    onPressed: onPressed,
    icon: Icon(
      visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
    ),
  );
}
