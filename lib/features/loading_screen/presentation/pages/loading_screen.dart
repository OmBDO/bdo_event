import 'package:flutter/material.dart';
import 'package:bdo_event/core/util/event.resource.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF1E6),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              AppAssets.logo,
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 28),
            const SizedBox(
              width: 100,
              height: 3,
              child: LinearProgressIndicator(
                minHeight: 0.3,
                color: Color.fromARGB(255, 233, 76, 4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
