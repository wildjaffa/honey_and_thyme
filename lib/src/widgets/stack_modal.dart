import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class StackModal extends StatelessWidget {
  final bool isOpen;
  final Widget child;
  final double height;
  final double width;
  final VoidCallback? onDismiss;

  const StackModal({
    super.key,
    required this.isOpen,
    required this.child,
    this.height = 300,
    this.width = 300,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: isOpen
          ? GestureDetector(
              key: const ValueKey('modal'),
              onTap: onDismiss,
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: Center(
                  child: GestureDetector(
                    onTap: () {}, // Prevent tap from bubbling up
                    child: Container(
                      width: width,
                      height: height,
                      decoration: BoxDecoration(
                        color: Constants.grayColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 10,
                            spreadRadius: 5,
                          )
                        ],
                      ),
                      child: child,
                    ),
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(key: ValueKey('empty')),
    );
  }
}
