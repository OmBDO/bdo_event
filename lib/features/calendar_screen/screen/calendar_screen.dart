import 'package:bdo_event/core/common/app_keyboard_tracker/app_keyboard_tracker.dart';
import 'package:bdo_event/core/common/calender_element/element/calendar_element.dart';
import 'package:bdo_event/core/common/footer_height_tracker/footer_height_tracker.dart';
import 'package:bdo_event/features/calendar_screen/widget/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class CalendarScreen extends StatefulWidget {
  // FIX: Renamed constructor from invalid keyword 'new'
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 70),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SearchBarWidget(),

              ValueListenableBuilder<bool>(
                valueListenable: AppKeyboardTracker.isKeyboardVisible,
                builder: (context, isKeyboardOpen, child) {
                  return AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: isKeyboardOpen
                        ? const SizedBox.shrink()
                        : const CalendarElement(),
                  );
                },
              ),

              const Gap(16),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return Material(
                    color: Colors.transparent,
                    child: ListTile(
                      title: const Text(
                        "Event",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onTap: () {}, // Ink splashes require an active tap handler trigger to paint
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: Image.network(
                            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTb7HjcEqxqMvO5FJXRu1Mn1c7Kc0eJFd_oOfdtWzUW7g&s=10",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => const Gap(10),
              ),

              ValueListenableBuilder<double>(
                valueListenable: FooterHeightTracker.heightNotifier,
                builder: (context, dynamicHeight, child) {
                  return SizedBox(height: dynamicHeight);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
