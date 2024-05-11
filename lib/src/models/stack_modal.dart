import 'package:flutter/material.dart';

class StackModal extends StatelessWidget {
  final bool isOpen;
  final Widget child;
  const StackModal({
    super.key,
    required this.isOpen,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 250),
      curve: Curves.decelerate,
      top: isOpen ? (screenHeight - 300) / 2 : screenHeight,
      left: (screenWidth - 300) / 2,
      child: Container(
        width: 300,
        height: 300,
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
