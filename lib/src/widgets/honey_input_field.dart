import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class HoneyInputField extends StatelessWidget {
  static const errorStyle = TextStyle(height: 0.1, fontSize: 8);
  static final hintStyle = GoogleFonts.imFellEnglish(
    color: Colors.black,
    fontSize: 18,
  );

  final String? initialValue;
  final String label;
  final void Function(String) onChanged;
  final String? Function(String?)? validator;
  final Widget? startingIcon;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextStyle? style;
  final double? width;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final bool autofocus;

  const HoneyInputField({
    super.key,
    required this.initialValue,
    required this.label,
    required this.onChanged,
    this.validator,
    this.startingIcon,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.style,
    this.width,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: SizedBox(
        width: width,
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                label,
              ),
            ),
            TextFormField(
              style: style,
              initialValue: initialValue,
              onChanged: onChanged,
              validator: validator,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              focusNode: focusNode,
              textInputAction: textInputAction,
              onFieldSubmitted: onFieldSubmitted,
              autofocus: autofocus,
              decoration: InputDecoration(icon: startingIcon),
            ),
          ],
        ),
      ),
    );
  }
}
