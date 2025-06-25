import 'package:flutter/material.dart';

class LoadingButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double loadingIndicatorSize;
  final double loadingIndicatorStrokeWidth;

  const LoadingButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.isLoading,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height,
    this.padding,
    this.loadingIndicatorSize = 20,
    this.loadingIndicatorStrokeWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: padding,
        ),
        child: isLoading
            ? SizedBox(
                width: loadingIndicatorSize,
                height: loadingIndicatorSize,
                child: CircularProgressIndicator(
                  strokeWidth: loadingIndicatorStrokeWidth,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    foregroundColor ?? Colors.white,
                  ),
                ),
              )
            : Text(text),
      ),
    );
  }
}
