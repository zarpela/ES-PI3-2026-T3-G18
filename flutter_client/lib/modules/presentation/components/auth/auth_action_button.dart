//feito por Abdallah Ali Borges El-Khatib - RA: 25018711
import 'package:flutter/material.dart';

class AuthActionButton extends StatelessWidget {
  const AuthActionButton({
    required this.label,
    required this.onPressed,
    this.isEnabled = true,
    this.isLoading = false,
    this.height = 58,
    this.labelStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    this.trailing,
    this.gradientColors,
    this.disabledGradientColors,
    this.backgroundColor,
    this.disabledBackgroundColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(28)),
    this.boxShadow,
    this.loadingIndicatorColor = Colors.white,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isEnabled;
  final bool isLoading;
  final double height;
  final TextStyle labelStyle;
  final Widget? trailing;
  final List<Color>? gradientColors;
  final List<Color>? disabledGradientColors;
  final Color? backgroundColor;
  final Color? disabledBackgroundColor;
  final BorderRadiusGeometry borderRadius;
  final List<BoxShadow>? boxShadow;
  final Color loadingIndicatorColor;

  bool get _canPress => isEnabled && !isLoading && onPressed != null;

  @override
  Widget build(BuildContext context) {
    final activeGradient = gradientColors;
    final inactiveGradient = disabledGradientColors;
    final useGradient = activeGradient != null && activeGradient.isNotEmpty;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: useGradient
              ? null
              : (_canPress
                    ? backgroundColor ?? const Color(0xFFC71E74)
                    : disabledBackgroundColor ?? const Color(0x4DC71E74)),
          gradient: useGradient
              ? LinearGradient(
                  colors: _canPress
                      ? activeGradient
                      : inactiveGradient ?? activeGradient,
                )
              : null,
          boxShadow: _canPress ? boxShadow : null,
        ),
        child: ElevatedButton(
          onPressed: _canPress ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: borderRadius),
            elevation: 0,
          ),
          child: isLoading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      loadingIndicatorColor,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(label, style: labelStyle),
                    if (trailing != null) ...[
                      const SizedBox(width: 8),
                      trailing!,
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
