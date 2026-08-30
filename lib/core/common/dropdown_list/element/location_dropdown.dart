import 'package:bdo_event/core/model/location_model/location_model.dart';
import 'package:flutter/material.dart';
import 'package:bdo_event/core/util/event_resource.dart';

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
    final theme = Theme.of(context);
    return PopupMenuButton<Location>(
      key: _menuKey,
      position: PopupMenuPosition.under,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(maxHeight: 190, minWidth: 220),
      color: theme.colorScheme.surface,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.4),
        ),
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
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.7),
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
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 10,
                    ),
                    horizontalTitleGap: AppSpace.space6,
                    minLeadingWidth: 0,
                    title: Text(
                      location.displayName,
                      style: TextStyle(
                        fontSize: AppSize.text14,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    subtitle: location.address == null
                        ? null
                        : Text(
                            location.address!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: AppSize.text11,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
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
                  Text(
                    AppText.location,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: AppSize.text11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    widget.selectedValue.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: AppSize.text14,
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
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
