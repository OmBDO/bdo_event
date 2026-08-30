import 'package:flutter/material.dart';
import 'package:bdo_event/core/util/event_resource.dart';
import 'package:gap/gap.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
            const Gap(AppSpace.space28),
            SizedBox(
              width: 100,
              height: 3,
              child: LinearProgressIndicator(
                minHeight: 0.3,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
