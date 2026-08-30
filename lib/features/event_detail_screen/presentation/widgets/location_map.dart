import 'package:bdo_event/core/util/ui/app_ui.dart';
import 'package:bdo_event/features/event_detail_screen/presentation/widgets/overlay_section.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class LocationSection extends StatefulWidget {
  const new({super.key, required this.widget});

  final OverlayCurveSection widget;

  @override
  State<LocationSection> createState() => _LocationSectionState();
}

class _LocationSectionState extends State<LocationSection> {
  bool _isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3, // Allocates a bit more space for text descriptions
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Icon(
              Icons.location_on_rounded,
              color: Theme.of(context).colorScheme.onSurface
                  .withValues(alpha: 0.26),
              size: 16,
            ),
          ),
          const Gap(AppSpace.space6),
          // Takes up all remaining room left by the icon
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Text(
                      widget.widget.widget.event.locationAddress ??
                          widget.widget.widget.event.location,
                      maxLines: _isExpanded ? null : 1,
                      style: TextStyle(
                        overflow: _isExpanded
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                        color: widget.widget.textGrey,
                        fontSize: AppSize.text14,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
                Semantics(
                  button: true,
                  toggled: _isExpanded,
                  label: _isExpanded ? 'Collapse address' : 'Expand address',
                  child: IconButton(
                    tooltip: _isExpanded
                        ? 'Collapse address'
                        : 'Expand address',
                    alignment: Alignment.topCenter,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    style: const ButtonStyle(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: widget.widget.textGrey,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
