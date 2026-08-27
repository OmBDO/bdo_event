// ignore: file_names
import 'package:flutter/material.dart';

class LocationDropdown extends StatefulWidget {
  final String selectedValue;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const LocationDropdown({
    super.key,
    required this.selectedValue,
    required this.items,
    required this.onChanged,
  });

  @override
  State<LocationDropdown> createState() => _LocationDropdownState();
}

class _LocationDropdownState extends State<LocationDropdown> {
  // 1. Structural tracking key and logic flags
  final GlobalKey<PopupMenuButtonState<String>> _menuKey = GlobalKey();
  bool _isMenuOpen = false;

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = true; // Set open status state line flag
    });

    // 2. Programmatically opens the PopupMenuButton overlay window panel
    _menuKey.currentState?.showButtonMenu();
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      key: _menuKey, // 👈 Register structural key link
      position: PopupMenuPosition.under,
      onSelected: (value) {
        setState(() {
          _isMenuOpen = false; // Reset arrow down state on choice selection tap
        });
        widget.onChanged(value);
      },
      // 🚀 CATCHES DISMISSAL: Flips arrow back down if user clicks outside the panel box to close it
      onCanceled: () {
        setState(() {
          _isMenuOpen = false;
        });
      },
      constraints: const BoxConstraints(maxHeight: 150, minWidth: 200),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          20,
        ), // Matches the inner ClipRRect curvature perfectly
        side: BorderSide(
          color: Colors.grey.withValues(
            alpha: 0.3,
          ), // 👈 Your desired border line color
          width: 1.9, // Border thickness
        ),
      ),
      color: Colors.white,
      elevation: 3,

      // Wrap child with InkWell to capture the tap event manually
      child: InkWell(
        onTap: _toggleMenu,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Location',
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 94, 0),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    widget.selectedValue,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // 3. 🚀 DYNAMIC ICON SWITCHING LOOP LOGIC BLOCK
            AnimatedRotation(
              // If the menu is open, rotate halfway (0.5 turns = 180 degrees)
              turns: _isMenuOpen ? 0.5 : 0.0,
              duration: const Duration(
                milliseconds: 250,
              ), // Smooth transition speed
              curve:
                  Curves.easeInOut, // Premium slow-fast-slow acceleration curve
              child: const Icon(
                Icons.keyboard_arrow_down_rounded, // 👈 Keep this as the down arrow; the rotation handles flipping it up!
                color: Colors.black54,
                size: 20,
              ),
            ),
          ],
        ),
      ),
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem<String>(
            enabled: false,
            padding: EdgeInsets.zero,
            child: SizedBox(
              height: 150,
              width: 220,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: ListView(
                  padding: EdgeInsets.zero, // 👈 Clears default ListView padding for crisp alignment

                  children: widget.items.asMap().entries.map((entry) {
                    String value = entry.value;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 12),
                          child: ListTile(
                            leading: Icon(
                              Icons.circle_outlined,
                              color: Colors.black,

                              size: 10,
                            ),
                            horizontalTitleGap: 6, // 👈 Controls the exact spacing between the bullet and the text
                            minLeadingWidth: 0,
                            title: Text(
                              value,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            dense: true,
                            onTap: () {
                              // Manually close selection menu box
                              Navigator.of(context).pop();

                              setState(() {
                                _isMenuOpen = false; // Reset arrow state on item selection
                              });

                              widget.onChanged(value);
                            },
                          ),
                        ),
                        // 🚀 THE FIX: Adds a thin, subtle divider line after every item except the last one

                        Divider(
                          height: 1, // Explicitly takes 1 pixel of layout height space
                          thickness: 2,
                          color: const Color.fromARGB(
                            255,
                            107,
                            107,
                            107,
                          ).withValues(alpha: 0.15), // Very faint line matching modern design profiles
                          indent: 20, // 👈 Aligns line perfectly with the start of your text
                          endIndent: 12, // Matches the right edge padding
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ];
      },
    );
  }
}
