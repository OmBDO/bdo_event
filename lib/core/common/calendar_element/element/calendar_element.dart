import 'package:bdo_event/core/common/app_keyboard_tracker/app_keyboard_tracker.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:bdo_event/core/util/event.resource.dart';

class CalendarElement extends StatefulWidget {
  const CalendarElement({super.key});

  @override
  State<CalendarElement> createState() => _CalendarElementState();
}

class _CalendarElementState extends State<CalendarElement> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final Map<DateTime, List<String>> _festivals = {
    DateTime(2026, 5, 1): [AppText.mayDayLabourDay],
    DateTime(2026, 8, 30): [AppText.techMeetupFestival],
    DateTime(2026, 9, 2): [AppText.companyHackathon],
    DateTime(2026, 9, 5): [AppText.teamBuildingMela],
    DateTime(2026, 11, 8): [AppText.diwaliFestival],
    DateTime(2026, 9, 14): [AppText.ganeshChaturthiGanapati],
  };

  List<String> _getFestivalsForDay(DateTime day) {
    final lookupDate = DateTime(day.year, day.month, day.day);
    return _festivals[lookupDate] ?? [];
  }

  @override
  void initState() {
    super.initState();
    AppKeyboardTracker.initialize();
  }

  @override
  Widget build(BuildContext context) {
    // Shared color palette variables for swift theme modifications
    const primaryColor = Color.fromARGB(255, 0, 0, 0); // Modern indigo
    const accentColor = Color(0xFFFF6584); // Elegant coral for festivals
    const textColor = Color(0xFF2D0C57); // Deep plum dark text

    return Container(
      margin: const EdgeInsets.only(top: 10, left: 16, right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          24,
        ), // Smooth premium rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.04,
            ), // Soft, non-muddy shadow projection
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        rowHeight: 48, // Balanced layout grid tracking space
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        eventLoader: _getFestivalsForDay,

        // 1. Premium Minimalism Header Styling
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible:
              false, // Clean look by hiding the format switcher toggle
          titleTextStyle: const TextStyle(
            color: textColor,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: 0.5,
          ),
          leftChevronIcon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: primaryColor,
            size: 18,
          ),
          rightChevronIcon: const Icon(
            Icons.arrow_forward_ios_rounded,
            color: primaryColor,
            size: 18,
          ),
          headerPadding: const EdgeInsets.only(bottom: 16),
        ),

        // 2. Clear Weekday Labels Configuration
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: Colors.black38,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          weekendStyle: TextStyle(
            color: accentColor,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),

        // 3. Grid Cell Render Overhaul
        calendarStyle: CalendarStyle(
          outsideDaysVisible:
              false, // Strips away trailing clutter days from other months
          defaultTextStyle: const TextStyle(
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
          weekendTextStyle: const TextStyle(
            color: accentColor,
            fontWeight: FontWeight.w500,
          ),

          // Current Day UI (Subtle Indicator Ring)
          todayDecoration: BoxDecoration(
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.4),
              width: 1.5,
            ),
            shape: BoxShape.circle,
          ),
          todayTextStyle: const TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),

          // User-Selected Day UI (Solid Background Accent Color)
          selectedDecoration: const BoxDecoration(
            color: primaryColor,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        // 4. Custom Marker Builder For Beautiful Festival Highlights
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (events.isEmpty) return const SizedBox.shrink();

            // Returns an accent-colored anchor indicator beneath the date digits text block
            return Container(
              margin: const EdgeInsets.only(bottom: 4),
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
              ),
            );
          },
        ),
      ),
    );
  }
}
