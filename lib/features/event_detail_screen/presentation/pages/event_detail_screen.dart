import 'package:bdo_event/features/event_detail_screen/presentation/widgets/background_decoration.dart';
import 'package:bdo_event/features/event_detail_screen/presentation/widgets/event_detail_header.dart';
import 'package:bdo_event/features/event_detail_screen/presentation/widgets/bottom_event_register_section.dart';
import 'package:bdo_event/features/event_detail_screen/presentation/widgets/overlay_section.dart';
import 'package:bdo_event/features/event_detail_screen/presentation/cubit/event_detail_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/features/event_detail_screen/presentation/cubit/event_detail_state.dart';
import 'package:bdo_event/core/di/app_dependencies.dart';
import 'package:bdo_event/core/prefs/recent_event_store.dart';
import 'package:bdo_event/features/auth_screen/domain/repositories/auth_repository.dart';

class EventDetailPage extends StatefulWidget {
  final Event event;

  const EventDetailPage({super.key, required this.event});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  @override
  void initState() {
    super.initState();
    getIt<RecentEventStore>().record(
      widget.event,
      userId: getIt<AuthRepositoryContract>().currentUser?.id,
    );
    context.read<EventDetailCubit>().checkRegistration(widget.event);
    context.read<EventDetailCubit>().loadAttendanceCount(widget.event);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryDark = theme.colorScheme.primary;
    final textGrey = theme.colorScheme.onSurface.withValues(alpha: 0.65);
    final mapBgColor = theme.colorScheme.surfaceContainerHighest;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          // 1. Background Cover Image Asset & Overlay Control Chevrons
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: BackgroundDecoration(widget: widget),
          ),

          EventDetailHeader(event: widget.event),

          // 2. Main Overlapping Rounded Bottom Content Sheet
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            left: 0,
            right: 0,
            bottom: 0,
            child: BlocBuilder<EventDetailCubit, EventDetailState>(
              builder: (context, state) => OverlayCurveSection(
                widget: widget,
                event: widget.event,
                textGrey: textGrey,
                primaryDark: primaryDark,
                mapBgColor: mapBgColor,
                attendanceCount: state.attendanceCount,
              ),
            ),
          ),

          // 5. Bottom Sticky Registration Action Deck Row
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomEventRegisterSection(
              textGrey: textGrey,
              widget: widget,
              primaryDark: primaryDark,
              event: widget.event,
            ),
          ),
        ],
      ),
    );
  }
}
