import 'package:bdo_event/core/model/location_model/location_model.dart';
import 'package:flutter/material.dart';

class LocationDropdown extends StatefulWidget {
  final Location selectedValue;
  final List<Location> items;
  final ValueChanged<Location?> onChanged;

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
  final GlobalKey<PopupMenuButtonState<Location>> _menuKey = GlobalKey();
  bool _isMenuOpen = false;

  void _openMenu() {
    setState(() => _isMenuOpen = true);
    _menuKey.currentState?.showButtonMenu();
  }

  void _selectLocation(Location location) {
    Navigator.of(context).pop();
    setState(() => _isMenuOpen = false);
    widget.onChanged(location);
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Location>(
      key: _menuKey,
      position: PopupMenuPosition.under,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(maxHeight: 190, minWidth: 220),
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      onSelected: (location) {
        setState(() => _isMenuOpen = false);
        widget.onChanged(location);
      },
      onCanceled: () => setState(() => _isMenuOpen = false),
      itemBuilder: (context) => [
        PopupMenuItem<Location>(
          enabled: false,
          padding: EdgeInsets.zero,
          child: SizedBox(
            height: 180,
            width: 220,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 6),
              itemCount: widget.items.length,
              separatorBuilder: (_, index) => Divider(
                height: 1,
                indent: 20,
                endIndent: 12,
                color: Colors.grey.withValues(alpha: 0.15),
              ),
              itemBuilder: (context, index) {
                final location = widget.items[index];
                return Material(
                  color: Colors.transparent,
                  child: ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.only(left: 20, right: 12),
                    leading: Icon(
                      Icons.circle_outlined,
                      color: Colors.black54,
                      size: 10,
                    ),
                    horizontalTitleGap: 6,
                    minLeadingWidth: 0,
                    title: Text(
                      location.displayName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    onTap: () => _selectLocation(location),
                  ),
                );
              },
            ),
          ),
        ),
      ],
      child: InkWell(
        onTap: _openMenu,
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
                      color: Color(0xFFFF5E00),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    widget.selectedValue.displayName,
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
            AnimatedRotation(
              turns: _isMenuOpen ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.black54,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
