import 'package:flutter/material.dart';
import 'package:bdo_event/core/util/event.resource.dart';

class SearchBarWidget extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final String hintText;

  const SearchBarWidget({
    super.key,
    this.onChanged,
    this.onFilterTap,
    this.hintText = AppText.searchFestivalsOrEvents,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFFF6584);
    const darkText = Color(0xFF2D0C57);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          16,
        ), // Balanced smooth rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.04,
            ), // Soft elegant non-muddy shadow projection
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        style: const TextStyle(
          color: darkText,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: darkText.withValues(alpha: 0.4),
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: primaryColor,
            size: 22,
          ),
          // Clear button shows up automatically only if text is input inside tracking loop
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear_rounded,
                    color: Colors.black38,
                    size: 20,
                  ),
                  onPressed: () {
                    _controller.clear();
                    if (widget.onChanged != null) widget.onChanged!('');
                    setState(
                      () {},
                    ); // Redraw to clear out the clear button asset
                  },
                )
              : widget.onFilterTap != null
              ? IconButton(
                  icon: const Icon(
                    Icons.tune_rounded,
                    color: primaryColor,
                    size: 20,
                  ),
                  onPressed: widget.onFilterTap,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        onTapOutside: (event) {
          FocusScope.of(context)
              .unfocus(); // Automatically hides keyboard when tapping outside
        },
      ),
    );
  }
}
