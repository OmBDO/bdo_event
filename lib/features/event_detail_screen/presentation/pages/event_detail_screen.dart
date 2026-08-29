import 'package:bdo_event/features/event_detail_screen/presentation/widgets/background_decoration.dart';
import 'package:bdo_event/features/event_detail_screen/presentation/widgets/event_detail_header.dart';
import 'package:bdo_event/features/event_detail_screen/presentation/widgets/bottom_event_register_section.dart';
import 'package:bdo_event/features/event_detail_screen/presentation/widgets/overlay_section.dart';
import 'package:bdo_event/features/event_detail_screen/presentation/cubit/event_detail_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/features/event_detail_screen/presentation/cubit/event_detail_state.dart';

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
    context.read<EventDetailCubit>().checkRegistration(widget.event);
    context.read<EventDetailCubit>().loadAttendanceCount(widget.event);
  }

  @override
  Widget build(BuildContext context) {
    const primaryDark = Color(0xFF111111);
    const textGrey = Color(0xFF7A7A7A);
    const mapBgColor = Color(0xFFE2EFF2);

    return Scaffold(
      backgroundColor: Colors.white,
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
