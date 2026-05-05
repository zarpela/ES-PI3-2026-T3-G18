import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuthInputField extends StatelessWidget {
  const AuthInputField({
    required this.label,
    required this.hint,
    this.controller,
    this.onChanged,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.inputFormatters,
    this.maxLength,
    this.labelColor = const Color(0xFF584048),
    this.labelFontSize = 12,
    this.labelFontWeight = FontWeight.bold,
    this.labelLetterSpacing = 0.5,
    this.fillColor = const Color(0xFFF6F1FF),
    this.textColor = const Color(0xFF201A1B),
    this.hintColor = const Color(0x66584048),
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 24,
      vertical: 22,
    ),
    this.margin = const EdgeInsets.only(bottom: 24),
    this.textAlign = TextAlign.start,
    this.textAlignVertical = TextAlignVertical.center,
    this.textStyle,
    super.key,
  });

  final String label;
  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final Color labelColor;
  final double labelFontSize;
  final FontWeight labelFontWeight;
  final double labelLetterSpacing;
  final Color fillColor;
  final Color textColor;
  final Color hintColor;
  final EdgeInsetsGeometry contentPadding;
  final EdgeInsetsGeometry margin;
  final TextAlign textAlign;
  final TextAlignVertical textAlignVertical;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontSize: labelFontSize,
              fontWeight: labelFontWeight,
              letterSpacing: labelLetterSpacing,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(32),
            ),
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              onChanged: onChanged,
              inputFormatters: inputFormatters,
              maxLength: maxLength,
              textAlign: textAlign,
              textAlignVertical: textAlignVertical,
              style: textStyle ?? TextStyle(color: textColor, fontSize: 16),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: contentPadding,
                hintText: hint,
                hintStyle: TextStyle(color: hintColor),
                counterText: maxLength == null ? null : '',
                suffixIcon: suffixIcon,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
