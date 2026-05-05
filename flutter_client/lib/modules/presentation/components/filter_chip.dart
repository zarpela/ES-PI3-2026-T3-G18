import 'package:flutter/material.dart';

class CustomFilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color softYellow;
  final Color panelBackground;
  final Color mutedText;

  const CustomFilterChip({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.softYellow,
    required this.panelBackground,
    required this.mutedText,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? softYellow : panelBackground,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFF655116) : mutedText,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}