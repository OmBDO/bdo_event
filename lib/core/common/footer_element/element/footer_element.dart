import 'dart:ui';

import 'package:bdo_event/core/common/footer_element/controller/footer_controller.dart';
import 'package:bdo_event/core/model/nav_item_model/nav_item_model.dart';
import 'package:flutter/material.dart';

class FooterElement extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const FooterElement({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<FooterElement> createState() => _FooterElementState();
}

class _FooterElementState extends State<FooterElement> {
  final _footerController = FooterController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _footerController.calculateFooterHeight(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Navigation items representing the buttons in your image
    final items = [
      NavItem(icon: Icons.calendar_month, label: 'Event'),
      NavItem(icon: Icons.app_registration_rounded, label: 'Register'),
      NavItem(icon: Icons.add_circle_outline_rounded, label: 'Create'),
      NavItem(icon: Icons.account_box, label: 'Profile'),
    ];

    return Container(
      key: _footerController.footerKey,
      padding: const EdgeInsets.only(bottom: 24.0, left: 24.0, right: 24.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 10,
            sigmaY: 10,
          ), // Frosty blur effect
          child: Container(
            height: 76,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.15,
              ), // Semi-transparent glass background
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(items.length, (index) {
                final isSelected = widget.currentIndex == index;

                return GestureDetector(
                  onTap: () {
                    widget.onTap(index);
                    _footerController.resetAppScrollTracker();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // The selected item gets a highlighted solid gradient background
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [Color(0xFFE96B47), Color(0xFFF18A6B)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : LinearGradient(
                              colors: [
                                Colors.black.withValues(alpha: 0.4),
                                Colors.black.withValues(alpha: 0.2),
                              ],
                            ),
                      border: Border.all(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.5)
                            : Colors.white.withValues(alpha: 0.1),
                        width: 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFFE96B47)
                                    .withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Icon(
                      items[index].icon,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
