import 'package:flutter/material.dart';

class BackOrAddButtons extends StatelessWidget {
  final void Function()? onAdd;
  final String addText;
  final String backRoute;
  final Widget? endWidget;

  const BackOrAddButtons({
    super.key,
    this.onAdd,
    required this.addText,
    required this.backRoute,
    this.endWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushNamed(context, backRoute);
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 45),
          child: ElevatedButton(
            onPressed: onAdd,
            child: Text(addText),
          ),
        ),
        if (endWidget != null) endWidget!,
      ],
    );
  }
}
