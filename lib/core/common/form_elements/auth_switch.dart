import 'package:flutter/material.dart';

class AuthSwitch extends StatelessWidget {
  final String prompt;
  final String action;
  final VoidCallback onTap;

  const AuthSwitch({
    super.key,
    required this.prompt,
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center, // Centers items horizontally
        crossAxisAlignment:
            WrapCrossAlignment.center, // Centers items vertically
        spacing: 4, // Horizontal space between items
        runSpacing: 4, // Vertical space if wrapped to new line
        children: [
          Text(
            prompt,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          TextButton(
            onPressed: onTap,
            // Removes internal padding so button text sits close to prompt
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(action),
          ),
        ],
      ),
    );
  }
}
