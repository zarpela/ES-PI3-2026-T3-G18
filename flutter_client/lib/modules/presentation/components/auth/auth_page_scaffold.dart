//feito por Abdallah Ali Borges El-Khatib - RA: 25018711
import 'package:flutter/material.dart';

class AuthPageScaffold extends StatelessWidget {
  const AuthPageScaffold({
    required this.child,
    this.appBar,
    this.backgroundColor = const Color(0xFFFCF8FF),
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
    this.showDecorations = false,
    this.topGlow = const AuthGlowDecoration(
      right: -60,
      top: 24,
      width: 256,
      height: 256,
      color: Color(0x0DC71E74),
      blurRadius: 100,
      spreadRadius: 20,
    ),
    this.bottomGlow = const AuthGlowDecoration(
      left: -60,
      bottom: 24,
      width: 320,
      height: 320,
      color: Color(0x0D5B559F),
      blurRadius: 120,
      spreadRadius: 20,
    ),
    super.key,
  });

  final PreferredSizeWidget? appBar;
  final Widget child;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;
  final bool showDecorations;
  final AuthGlowDecoration topGlow;
  final AuthGlowDecoration bottomGlow;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      body: Stack(
        children: [
          if (showDecorations) ...[
            _AuthBackgroundGlow(decoration: topGlow),
            _AuthBackgroundGlow(decoration: bottomGlow),
          ],
          SafeArea(
            child: SingleChildScrollView(padding: padding, child: child),
          ),
        ],
      ),
    );
  }
}

class AuthGlowDecoration {
  const AuthGlowDecoration({
    required this.width,
    required this.height,
    required this.color,
    required this.blurRadius,
    required this.spreadRadius,
    this.top,
    this.right,
    this.bottom,
    this.left,
  });

  final double width;
  final double height;
  final Color color;
  final double blurRadius;
  final double spreadRadius;
  final double? top;
  final double? right;
  final double? bottom;
  final double? left;
}

class _AuthBackgroundGlow extends StatelessWidget {
  const _AuthBackgroundGlow({required this.decoration});

  final AuthGlowDecoration decoration;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: decoration.top,
      right: decoration.right,
      bottom: decoration.bottom,
      left: decoration.left,
      child: Container(
        width: decoration.width,
        height: decoration.height,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: decoration.color,
              blurRadius: decoration.blurRadius,
              spreadRadius: decoration.spreadRadius,
            ),
          ],
        ),
      ),
    );
  }
}
