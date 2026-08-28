import 'package:flutter/material.dart';

class EventDropdown extends StatelessWidget {
  final String selectedLocation;
  final List<String> locations;
  final ValueChanged<String> onChanged;

  const EventDropdown({
    super.key,
    required this.selectedLocation,
    required this.locations,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 200,
      child: Row(
        children: [
          const Icon(Icons.location_on, size: 18),

          const SizedBox(width: 4),

          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedLocation,
              icon: const Icon(Icons.keyboard_arrow_down, size: 18),
              isDense: true,

              items: locations.map((location) {
                return DropdownMenuItem<String>(
                  value: location,
                  child: Text(
                    location,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),

              onChanged: (value) {
                if (value != null) {
                  onChanged(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
