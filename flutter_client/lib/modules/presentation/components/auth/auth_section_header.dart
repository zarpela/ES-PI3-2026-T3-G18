//feito por Abdallah Ali Borges El-Khatib - RA: 25018711

import 'package:flutter/material.dart';

class AuthSectionHeader extends StatelessWidget {
  const AuthSectionHeader({
    required this.title,
    required this.subtitle,
    this.titleColor = const Color(0xFF170B58),
    this.subtitleColor = const Color(0xFF584048),
    this.titleFontSize = 36,
    this.titleHeight = 1.1,
    this.subtitleFontSize = 16,
    this.topSpacing = 0,
    this.bottomSpacing = 40,
    super.key,
  });

  final String title;
  final String subtitle;
  final Color titleColor;
  final Color subtitleColor;
  final double titleFontSize;
  final double titleHeight;
  final double subtitleFontSize;
  final double topSpacing;
  final double bottomSpacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (topSpacing > 0) SizedBox(height: topSpacing),
        Text(
          title,
          style: TextStyle(
            color: titleColor,
            fontSize: titleFontSize,
            fontWeight: FontWeight.w900,
            height: titleHeight,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          subtitle,
          style: TextStyle(
            color: subtitleColor,
            fontSize: subtitleFontSize,
            height: 1.5,
          ),
        ),
        SizedBox(height: bottomSpacing),
      ],
    );
  }
}
