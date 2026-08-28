import 'package:flutter/material.dart';

class AppDropDownField<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final String label;
  final IconData icon;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;

  const AppDropDownField({
    super.key, // Fixed the invalid 'const new' syntax
    required this.value,
    required this.items,
    required this.label,
    required this.icon,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      // Matches the decoration styles exactly with your AppTextField
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      // Styling customization to match form text fields cleanly
      icon: const Icon(Icons.arrow_drop_down),
      isExpanded: true, // Prevents text overflow if category names are long
      borderRadius: BorderRadius.circular(16), // Match dropdown overlay curve
    );
  }
}
