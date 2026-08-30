import 'package:bdo_event/core/util/event_resource.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ConfigurationErrorApp extends StatelessWidget {
  const ConfigurationErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppText.appName,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined, size: 56),
                const Gap(AppSpace.space16),
                const Text(
                  AppText.configurationRequired,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppSize.text20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(AppSpace.space8),
                const Text(
                  AppText.configurationInstructions,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
