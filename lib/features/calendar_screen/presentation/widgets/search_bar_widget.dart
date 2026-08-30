import 'package:bdo_event/core/model/user_model/user_model.dart';
import 'package:bdo_event/features/profile_screen/presentation/cubit/profile_screen_cubit.dart';
import 'package:bdo_event/features/profile_screen/presentation/cubit/profile_screen_state.dart';
import 'package:bdo_event/features/watcher_screen/presentation/pages/watcher_scan_screen.dart';
import 'package:flutter/material.dart';
import 'package:bdo_event/core/util/event_resource.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    return BlocBuilder<ProfileScreenCubit, ProfileScreenState>(
      builder: (context, profileState) {
        final theme = Theme.of(context);
        final isDarkMode = theme.brightness == Brightness.dark;
        final primaryColor = isDarkMode
            ? theme.colorScheme.primary
            : const Color(0xFFFF6584);
        final textColor = theme.colorScheme.onSurface;
        final user = profileState.user;
        final canScan =
            user?.hasPermission(UserPermission.scanRegistrations) ?? false;
        return Row(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(
                  top: 8,
                  bottom: 8,
                  left: 16,
                  right: 12,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(
                    16,
                  ), // Balanced smooth rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withValues(
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
                  style: TextStyle(
                    color: textColor,
                    fontSize: AppSize.text15,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: TextStyle(
                      color: textColor.withValues(alpha: 0.4),
                      fontSize: AppSize.text15,
                      fontWeight: FontWeight.w400,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: primaryColor,
                      size: 22,
                    ),
                    // Clear button shows up automatically only if text is input inside tracking loop
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear_rounded,
                              color: textColor.withValues(alpha: 0.38),
                              size: 20,
                            ),
                            onPressed: () {
                              _controller.clear();
                              if (widget.onChanged != null) {
                                widget.onChanged!('');
                              }
                              setState(
                                () {},
                              ); // Redraw to clear out the clear button asset
                            },
                          )
                        : widget.onFilterTap != null
                        ? IconButton(
                            icon: Icon(
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
                    FocusScope.of(context).unfocus(); // Automatically hides keyboard when tapping outside
                  },
                ),
              ),
            ),
            if (canScan)
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(
                    14,
                  ), // Balanced smooth rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withValues(
                        alpha: 0.04,
                      ), // Soft elegant non-muddy shadow projection
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                margin: const EdgeInsets.only(top: 8, bottom: 8, right: 16),
                child: IconButton(
                  iconSize: 34,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WatcherScanScreen(),
                      ),
                    );
                  },
                  icon: Icon(Icons.qr_code),
                ),
              ),
          ],
        );
      },
    );
  }
}
