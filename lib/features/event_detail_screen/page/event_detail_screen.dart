// Location: lib/features/event_screen/screen/event_detail_page.dart
import 'package:bdo_event/features/event_detail_screen/widget/backgroundImage.dart';
import 'package:bdo_event/features/event_detail_screen/widget/bottom_register.dart';
import 'package:bdo_event/features/event_detail_screen/widget/overlay_section.dart';
import 'package:flutter/material.dart';
import 'package:bdo_event/core/model/event_model/event_model.dart';

class EventDetailPage extends StatefulWidget {
  final Event event;

  const EventDetailPage({super.key, required this.event});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
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

          // 2. Main Overlapping Rounded Bottom Content Sheet
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            left: 0,
            right: 0,
            bottom: 0,
            child: OverlayCurveSection(
              widget: widget,
              textGrey: textGrey,
              primaryDark: primaryDark,
              mapBgColor: mapBgColor,
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
