import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/di/app_dependencies.dart';
import 'package:bdo_event/features/event_detail_screen/presentation/pages/event_detail_screen.dart';
import 'package:bdo_event/features/event_detail_screen/presentation/cubit/event_detail_cubit.dart';
import 'package:bdo_event/features/event_detail_screen/presentation/cubit/event_detail_state.dart';
import 'package:bdo_event/features/event_screen/presentation/cubit/event_screen_cubit.dart';
import 'package:bdo_event/features/calendar_screen/presentation/cubit/calendar_screen_cubit.dart';
import 'package:bdo_event/features/registered_screen/presentation/pages/registered_event_page.dart';
import 'package:bdo_event/features/registered_screen/presentation/cubit/registered_event_cubit.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bdo_event/core/util/event_resource.dart';

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
    final cubit = context.read<EventDetailCubit>();
    final bool isFull =
        event.capacity != null && event.attendeeCount >= event.capacity!;
    final bool isPastRegistrationDeadline =
      event.registrationDeadline != null &&
      !DateTime.now().isBefore(event.registrationDeadline!);

    return BlocBuilder<EventDetailCubit, EventDetailState>(
      bloc: cubit,
      builder: (context, state) {
        final theme = Theme.of(context);
        final bool isAlreadyRegistered = state.isRegistered;

        String statusText = AppText.available;
        Color statusColor = Colors.green.shade700;

        String buttonText = AppText.register;
        Color buttonBgColor = primaryDark;
        Color buttonForegroundColor = theme.colorScheme.onPrimary;

        VoidCallback? buttonAction;

        if (isAlreadyRegistered) {
          statusText = AppText.registered;
          statusColor = Colors.blue.shade700;
          buttonText = AppText.myTicket;
          buttonBgColor = theme.colorScheme.secondaryContainer;
          buttonForegroundColor = theme.colorScheme.onSecondaryContainer;

          buttonAction = () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => getIt<RegisteredEventCubit>(),
                  child: RegisteredEventPage(event: event),
                ),
              ),
            );
            if (!context.mounted) return;
            cubit.checkRegistration(event);
            context.read<EventScreenCubit>().load(force: true);
            context.read<CalendarScreenCubit>().loadRegistrations();
          };
        } else if (!event.isAvailable) {
          statusText = AppText.unavailable;
          statusColor = textGrey;
          buttonText = AppText.registrationClosed;
          buttonAction = null;
        } else if (isFull) {
          statusText = AppText.eventFull;
          statusColor = Colors.red.shade700;
          buttonText = AppText.fullyBooked;
          buttonAction = null;
        } else if (isPastRegistrationDeadline) {
          statusText = AppText.registrationClosed;
          statusColor = textGrey;
          buttonText = AppText.registrationClosed;
          buttonAction = null;
        } else {
          // Action mapping: Fires real booking updates through the secondary repository
          buttonAction = () async {
            final error = await cubit.register(event);
            if (!context.mounted) return;

            if (error == null) {
              context.read<EventScreenCubit>().load(force: true);
              context.read<CalendarScreenCubit>().loadRegistrations();
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error ?? AppText.eventRegistered),
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
            color: theme.colorScheme.surface,
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
                    AppText.status,
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
                    onPressed: state.isSubmitting ? null : buttonAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonBgColor,
                      foregroundColor: buttonForegroundColor,
                        disabledBackgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                        disabledForegroundColor:
                          Theme.of(context).colorScheme.onSurfaceVariant,
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
