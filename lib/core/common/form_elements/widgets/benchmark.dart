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
            color: const Color(0xFF2D0C57),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
        ),
        const SizedBox(width: 12),
        const Text(
          AppText.brandName,
          style: TextStyle(
            color: Color(0xFF2D0C57),
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
