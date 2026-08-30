import 'package:flutter/material.dart';

class ScannerIconButton extends StatelessWidget {
  const ScannerIconButton({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).colorScheme.surfaceContainerHighest
          : Colors.black54,
      borderRadius: BorderRadius.circular(24),
    ),
    child: IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
        color: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).colorScheme.onSurface
          : Colors.white,
      icon: Icon(icon),
    ),
  );
}
