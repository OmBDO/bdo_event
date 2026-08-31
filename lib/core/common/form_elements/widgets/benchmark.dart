import 'package:bdo_event/core/util/resource/app_text.dart';
import 'package:bdo_event/core/util/ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            Icons.auto_awesome_rounded,
            color: Theme.of(context).colorScheme.onSecondary,
          ),
        ),
        const Gap(AppSpace.space12),
        Text(
          AppText.brandName,
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontSize: AppSize.text20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
