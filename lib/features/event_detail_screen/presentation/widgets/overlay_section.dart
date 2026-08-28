import 'package:bdo_event/features/event_detail_screen/presentation/pages/event_detail_screen.dart';
import 'package:bdo_event/features/event_detail_screen/presentation/widgets/map_lines_painter.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:bdo_event/core/util/event.resource.dart';

class OverlayCurveSection extends StatelessWidget {
  const OverlayCurveSection({
    super.key,
    required this.widget,
    required this.textGrey,
    required this.primaryDark,
    required this.mapBgColor,
  });

  final EventDetailPage widget;
  final Color textGrey;
  final Color primaryDark;
  final Color mapBgColor;

  // Multi-Avatar Layering GeneratorWidget
  SizedBox _buildAvatarStack() {
    const avatarColors = [Colors.teal, Colors.indigo, Colors.deepOrange];
    return SizedBox(
      width: 76,
      height: 28,
      child: Stack(
        children: [
          ...List.generate(avatarColors.length, (index) {
            return Positioned(
              left: index * 16.0,
              child: CircleAvatar(
                radius: 14,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 13,
                  backgroundColor: avatarColors[index],
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 15,
                  ),
                ),
              ),
            );
          }),
          Positioned(
            left: avatarColors.length * 16.0,
            child: CircleAvatar(
              radius: 14,
              backgroundColor: Colors.amber.shade100,
              child: const Text(
                "99+",
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(36),
          topRight: Radius.circular(36),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          24,
          28,
          24,
          110,
        ), // Bottom padding leaves space for sticky deck
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location Meta String Header
            Row(
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  color: Colors.black26,
                  size: 16,
                ),
                const Gap(6),
                Text(
                  widget.event.location,
                  style: TextStyle(
                    color: textGrey,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Gap(12),

            const Text(
              AppText.upcomingEvent,
              style: TextStyle(
                color: Colors.deepOrange,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
              ),
            ),
            const Gap(8),

            // Main Title Header
            Text(
              widget.event.title,
              style: TextStyle(
                color: primaryDark,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                height: 1.25,
                letterSpacing: -0.3,
              ),
            ),
            const Gap(14),

            // Description Summary Details Text block
            Text(
              AppText.eventDetailDescription,
              style: TextStyle(
                color: textGrey,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
            const Gap(24),

            // 3. Attendance Counter Face Pile Badge Wrapper Block
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F7F9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  _buildAvatarStack(),
                  const Gap(12),
                  Text(
                    AppText.attend100Plus,
                    style: TextStyle(
                      color: primaryDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 10,
                      color: primaryDark,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(16),

            // 4. Clean Vector Roadmap Placeholder Widget Container
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: mapBgColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    // Abstract Mock Grid Roads Vector Layout Drawing Loop
                    CustomPaint(
                      size: Size.infinite,
                      painter: MapLinesPainter(),
                    ),
                    // Central Floating Target Marker Ring
                    Positioned(
                      top: 65,
                      left: 140,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.orange.shade800,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                          ),
                          const Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                    // Secondary Grey Anchor Dots
                    const Positioned(
                      top: 40,
                      right: 80,
                      child: CircleAvatar(
                        radius: 6,
                        backgroundColor: Colors.black26,
                      ),
                    ),
                    const Positioned(
                      bottom: 30,
                      left: 60,
                      child: CircleAvatar(
                        radius: 8,
                        backgroundColor: Colors.black12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
