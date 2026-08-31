import 'package:bdo_event/core/common/app_keyboard_tracker/app_keyboard_tracker.dart';
import 'package:bdo_event/core/common/calendar_element/widgets/event_tooltip.dart';
import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/util/event_schedule.dart';
import 'package:bdo_event/core/util/ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:bdo_event/core/theme/app_colors.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarElement extends StatefulWidget {
  const CalendarElement({super.key, this.events = const [], this.onEventTap});

  final List<Event> events;
  final Future<void> Function(Event event)? onEventTap;

  @override
  State<CalendarElement> createState() => _CalendarElementState();
}

class _CalendarElementState extends State<CalendarElement> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  OverlayEntry? _eventTooltip;

  List<Event> _getEventsForDay(DateTime day) => widget.events.where((event) {
    final eventDate = EventSchedule.eventDate(event);
    return eventDate != null && isSameDay(eventDate, day);
  }).toList();

  void _hideEventTooltip() {
    _eventTooltip?.remove();
    _eventTooltip = null;
  }

  void _showEventTooltip(BuildContext context, Event event) {
    _hideEventTooltip();
    final box = context.findRenderObject() as RenderBox;
    final anchor = box.localToGlobal(Offset.zero);
    final tooltipWidth = MediaQuery.sizeOf(context).width - 32;

    _eventTooltip = OverlayEntry(
      builder: (_) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _hideEventTooltip,
            ),
          ),
          Positioned(
            left: 16,
            top: anchor.dy + 74,
            width: tooltipWidth,
            child: Column(
              children: [
                EventTooltip(
                  event: event,
                  onDismiss: _hideEventTooltip,
                  onOpen: () async {
                    await widget.onEventTap?.call(event);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
    Overlay.of(context).insert(_eventTooltip!);
  }

  @override
  void dispose() {
    _hideEventTooltip();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    AppKeyboardTracker.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final primaryColor = isDarkMode ? theme.colorScheme.primary : Colors.black;
    final accentColor = isDarkMode
        ? theme.colorScheme.tertiary
        : const Color(0xFFFF6584);
    final textColor = isDarkMode
        ? theme.colorScheme.onSurface
        : AppColors.secondaryLight;

    return Container(
      margin: const EdgeInsets.only(top: 10, left: 16, right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
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
          final events = _getEventsForDay(selectedDay);
          if (events.isNotEmpty) {
            _showEventTooltip(context, events.first);
          }
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        eventLoader: (day) => _getEventsForDay(day),

        // 1. Premium Minimalism Header Styling
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible:
              false, // Clean look by hiding the format switcher toggle
          titleTextStyle: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w800,
            fontSize: AppSize.text18,
            letterSpacing: 0.5,
          ),
          leftChevronIcon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: primaryColor,
            size: 18,
          ),
          rightChevronIcon: Icon(
            Icons.arrow_forward_ios_rounded,
            color: primaryColor,
            size: 18,
          ),
          headerPadding: const EdgeInsets.only(bottom: 16),
        ),

        // 2. Clear Weekday Labels Configuration
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: textColor.withValues(alpha: 0.55),
            fontWeight: FontWeight.w600,
            fontSize: AppSize.text13,
          ),
          weekendStyle: TextStyle(
            color: accentColor,
            fontWeight: FontWeight.w600,
            fontSize: AppSize.text13,
          ),
        ),

        // 3. Grid Cell Render Overhaul
        calendarStyle: CalendarStyle(
          outsideDaysVisible:
              false, // Strips away trailing clutter days from other months
          defaultTextStyle: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
          weekendTextStyle: TextStyle(
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
          todayTextStyle: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),

          // User-Selected Day UI (Solid Background Accent Color)
          selectedDecoration: BoxDecoration(
            color: primaryColor,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: TextStyle(
            color: theme.colorScheme.onPrimary,
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
              decoration: BoxDecoration(
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
