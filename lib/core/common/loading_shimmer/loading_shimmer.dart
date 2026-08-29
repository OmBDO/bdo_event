import 'package:flutter/material.dart';

class AppShimmer extends StatefulWidget {
  const AppShimmer({super.key, required this.child});

  final Widget child;

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    child: widget.child,
    builder: (context, child) => ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment(-1.5 + (_controller.value * 3), -0.2),
        end: Alignment(-0.5 + (_controller.value * 3), 0.2),
        colors: const [
          Color(0xFFFFDCC8),
          Color(0xFFFFF8F2),
          Color(0xFFFFCDB5),
        ],
      ).createShader(bounds),
      child: child,
    ),
  );
}

class EventListShimmer extends StatelessWidget {
  const EventListShimmer({super.key});

  @override
  Widget build(BuildContext context) => ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: 4,
    itemBuilder: (context, index) => AppShimmer(
      child: Container(
        height: 106,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFE9DB),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD5C0),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ShimmerLine(width: double.infinity, height: 16),
                  const SizedBox(height: 12),
                  _ShimmerLine(width: 130, height: 12),
                  const SizedBox(height: 8),
                  _ShimmerLine(width: 170, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class NotificationListShimmer extends StatelessWidget {
  const NotificationListShimmer({super.key});

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
    itemCount: 4,
    separatorBuilder: (_, __) => const SizedBox(height: 12),
    itemBuilder: (context, index) => AppShimmer(
      child: Container(
        height: 142,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFE9DB),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const _ShimmerCircle(size: 24),
                const SizedBox(width: 10),
                Expanded(child: _ShimmerLine(width: double.infinity, height: 16)),
              ],
            ),
            const SizedBox(height: 16),
            const _ShimmerLine(width: double.infinity, height: 12),
            const SizedBox(height: 8),
            const _ShimmerLine(width: 220, height: 12),
            const Spacer(),
            const _ShimmerLine(width: 100, height: 12),
          ],
        ),
      ),
    ),
  );
}

class AttendeeListShimmer extends StatelessWidget {
  const AttendeeListShimmer({super.key});

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
    itemCount: 6,
    separatorBuilder: (_, __) => const SizedBox(height: 10),
    itemBuilder: (context, index) => AppShimmer(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        leading: const _ShimmerCircle(size: 48),
        title: const _ShimmerLine(width: 170, height: 16),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: _ShimmerLine(width: 220, height: 12),
        ),
      ),
    ),
  );
}

class AttendeeSummaryShimmer extends StatelessWidget {
  const AttendeeSummaryShimmer({super.key});

  @override
  Widget build(BuildContext context) => AppShimmer(
    child: Row(
      children: [
        const _ShimmerCircle(size: 28),
        const SizedBox(width: 4),
        const _ShimmerCircle(size: 28),
        const SizedBox(width: 12),
        const _ShimmerLine(width: 112, height: 14),
        const Spacer(),
        const _ShimmerCircle(size: 28),
      ],
    ),
  );
}

class _ShimmerLine extends StatelessWidget {
  const _ShimmerLine({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: const Color(0xFFFFD5C0),
      borderRadius: BorderRadius.circular(height / 2),
    ),
  );
}

class _ShimmerCircle extends StatelessWidget {
  const _ShimmerCircle({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: const BoxDecoration(
      color: Color(0xFFFFD5C0),
      shape: BoxShape.circle,
    ),
  );
}