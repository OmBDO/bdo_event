import 'package:flutter/material.dart';

class EventTab extends StatelessWidget {
  final List<String> titles;
  final bool isSelected;
  final VoidCallback onTap;

  const EventTab({
    super.key,
    required this.titles,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      height: 40,
      child: ListView.separated(
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(width: 12);
        },
        scrollDirection: Axis.horizontal,
        itemCount: titles.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                titles[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
