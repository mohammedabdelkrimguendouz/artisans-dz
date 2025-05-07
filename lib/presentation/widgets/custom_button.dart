import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final double? width;
  final double height;
  final double borderRadius;
  final double iconSize;
  final double fontSize;
  final FontWeight fontWeight;
  final EdgeInsetsGeometry padding;

  const CustomButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
    this.width,
    this.height = 48,
    this.borderRadius = 10,
    this.iconSize = 18,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w600,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: borderColor != null
                ? BorderSide(color: borderColor!, width: 1.2)
                : BorderSide.none,
          ),
          padding: padding,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: iconSize),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}