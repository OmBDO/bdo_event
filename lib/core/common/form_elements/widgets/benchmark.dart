import 'package:flutter/material.dart';
import 'package:bdo_event/core/util/event.resource.dart';

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
        const SizedBox(width: 12),
        Text(
          AppText.brandName,
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
