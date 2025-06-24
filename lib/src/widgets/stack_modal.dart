import 'package:flutter/material.dart';

class StackModal extends StatelessWidget {
  final bool isOpen;
  final Widget child;
  final double height;
  final double width;
  const StackModal({
    super.key,
    required this.isOpen,
    required this.child,
    this.height = 300,
    this.width = 300,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 250),
      curve: Curves.decelerate,
      top: isOpen ? (screenHeight - height) / 2 : screenHeight,
      left: (screenWidth - width) / 2,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 5,
            )
          ],
        ),
        child: child,
      ),
    );
  }
}
