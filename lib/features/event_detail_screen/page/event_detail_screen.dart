// Location: lib/features/event_screen/screen/event_detail_page.dart
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class EventDetailPage extends StatelessWidget {
  const EventDetailPage({super.key});

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
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://unsplash.com'),
                  fit: BoxFit.cover,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back Circle Button
                      CircleAvatar(
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        radius: 20,
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      // More Circle Button
                      CircleAvatar(
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        radius: 20,
                        child: const Icon(
                          Icons.more_vert_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. Main Overlapping Rounded Bottom Content Sheet Sheet
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
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
                      children: const [
                        Icon(
                          Icons.location_on_rounded,
                          color: Colors.black26,
                          size: 16,
                        ),
                        Gap(6),
                        Text(
                          "New York, USA",
                          style: TextStyle(
                            color: textGrey,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Gap(12),

                    // Main Title Header
                    const Text(
                      "AI Global Leadership\nFuture Summit",
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
                    const Text(
                      "AI Global Leadership Future Summit unites global leaders to explore innovation, share insights, and shape the future of technology worldwide...",
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
                          const Text(
                            "Attend 100+",
                            style: TextStyle(
                              color: primaryDark,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          const CircleAvatar(
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
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3,
                                      ),
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
            ),
          ),

          // 5. Bottom Sticky Pricing Purchase Action Deck Row
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
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
                    children: const [
                      Text(
                        "Starting from",
                        style: TextStyle(
                          color: textGrey,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Gap(4),
                      Text(
                        "\$350.00",
                        style: TextStyle(
                          color: primaryDark,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 32),
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryDark,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Buy Ticket",
                          style: TextStyle(
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
            ),
          ),
        ],
      ),
    );
  }

  // Multi-Avatar Layering GeneratorWidget
  SizedBox _buildAvatarStack() {
    const urls = ['unsplash.com', 'unsplash.com', 'unsplash.com'];
    return SizedBox(
      width: 76,
      height: 28,
      child: Stack(
        children: List.generate(urls.length + 1, (index) {
          if (index == urls.length) {
            return Positioned(
              left: index * 16.0,
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
            );
          }
          return Positioned(
            left: index * 16.0,
            child: CircleAvatar(
              radius: 14,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 13,
                backgroundImage: NetworkImage(urls[index]),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// Custom Painter to build standard minimalistic map road paths lines loops
class MapLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path1 = Path()
      ..moveTo(0, size.height * 0.3)
      ..lineTo(size.width * 0.4, size.height * 0.4)
      ..lineTo(size.width, size.height * 0.1);
    final path2 = Path()
      ..moveTo(size.width * 0.2, 0)
      ..lineTo(size.width * 0.5, size.height)
      ..lineTo(size.width * 0.8, size.height * 0.2);
    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
