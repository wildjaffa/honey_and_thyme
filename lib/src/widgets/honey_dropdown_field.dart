import 'package:flutter/material.dart';

class HoneyDropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final void Function(T?) onChanged;
  final String? Function(T?)? validator;
  final Widget? startingIcon;
  final double? width;
  final bool enabled;
  final String? hintText;
  final String? errorText;
  final bool isExpanded;

  const HoneyDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.startingIcon,
    this.width,
    this.enabled = true,
    this.hintText,
    this.errorText,
    this.isExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                label,
              ),
            ),
            DropdownButtonFormField<T>(
              value: value,
              items: items
                  .map((item) => DropdownMenuItem<T>(
                        value: item,
                        child: Text(item.toString()),
                      ))
                  .toList(),
              onChanged: enabled ? onChanged : null,
              validator: validator,
              isExpanded: isExpanded,
              hint: hintText != null ? Text(hintText!) : null,
              icon: const Icon(Icons.arrow_drop_down),
              iconSize: 24,
              elevation: 16,
              menuMaxHeight: 300,
            ),
          ],
        ),
      ),
    );
  }
}
