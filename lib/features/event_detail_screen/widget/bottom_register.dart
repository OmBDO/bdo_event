import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/features/auth_screen/auth_repository.dart'; // Handles User Data & Notifier hooks
import 'package:bdo_event/features/event_detail_screen/page/event_detail_screen.dart';
import 'package:bdo_event/features/event_detail_screen/repository/registered_event_repo.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class BottomEventRegisterSection extends StatelessWidget {
  const BottomEventRegisterSection({
    super.key,
    required this.textGrey,
    required this.widget,
    required this.primaryDark,
    required this.event,
  });

  final Color textGrey;
  final EventDetailPage widget;
  final Event event;
  final Color primaryDark;

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final bool isFull =
        event.capacity != null && event.attendeeCount >= event.capacity!;

    // 1. Listen to global registration updates via AuthRepository
    return ValueListenableBuilder<List<Event>>(
      valueListenable: AuthRepository.registrations,
      builder: (context, registeredList, child) {
        // 2. Check current validation states via RegisteredEventRepository
        final bool isAlreadyRegistered =
            RegisteredEventRepository.isUserRegistered(event.id);

        String statusText = "Available";
        Color statusColor = Colors.green.shade700;

        String buttonText = "Register";
        Color buttonBgColor = primaryDark;
        Color buttonForegroundColor = Colors.white;

        VoidCallback? buttonAction;

        if (isAlreadyRegistered) {
          statusText = "Registered";
          statusColor = Colors.blue.shade700;
          buttonText = "Cancel Registration";
          buttonBgColor = Colors.red.shade50;
          buttonForegroundColor = Colors.red.shade700;

          // Action mapping: Fires real cancellation updates through the secondary repository
          buttonAction = () async {
            final error = await RegisteredEventRepository.cancelRegistration(
              event,
            );
            if (!context.mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  error ?? 'Your registration was cancelled successfully.',
                ),
                backgroundColor: error != null
                    ? Colors.red.shade800
                    : Colors.blue.shade800,
              ),
            );
          };
        } else if (!event.isAvailable) {
          statusText = "Unavailable";
          statusColor = textGrey;
          buttonText = "Registration Closed";
          buttonAction = null;
        } else if (isFull) {
          statusText = "Event Full";
          statusColor = Colors.red.shade700;
          buttonText = "Fully Booked";
          buttonAction = null;
        } else {
          // Action mapping: Fires real booking updates through the secondary repository
          buttonAction = () async {
            final error = await RegisteredEventRepository.registerEvent(event);
            if (!context.mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error ?? 'Event registered successfully!'),
                backgroundColor: error != null
                    ? Colors.red.shade800
                    : Colors.green.shade800,
              ),
            );
          };
        }

        return Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "STATUS",
                    style: TextStyle(
                      color: textGrey,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Gap(3),
                  Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 32),
                  child: ElevatedButton(
                    onPressed: buttonAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonBgColor,
                      foregroundColor: buttonForegroundColor,
                      disabledBackgroundColor: Colors.grey.shade200,
                      disabledForegroundColor: Colors.grey.shade500,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      buttonText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
