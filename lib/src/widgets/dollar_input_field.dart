import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:honey_and_thyme/src/widgets/honey_input_field.dart';
import 'package:honey_and_thyme/utils/validations.dart';

class DollarInputField extends StatelessWidget {
  final String label;
  final double? initialValue;
  final void Function(double) onChanged;
  final TextStyle? style;

  void dollarChanged(String value) {
    final double? parsed = double.tryParse(value);
    if (parsed == null) {
      onChanged(0.0);
      return;
    }
    onChanged(parsed);
  }

  const DollarInputField({
    super.key,
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return HoneyInputField(
      initialValue: initialValue.toString(),
      label: label,
      onChanged: dollarChanged,
      validator: dollarInputValidation,
      startingIcon: Text(
        '\$',
        style: HoneyInputField.hintStyle,
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      style: style,
    );
  }
}
