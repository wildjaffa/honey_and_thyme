String? dollarInputValidation(String? value) {
  if (value == null) return 'Please enter a value';
  final parsed = double.tryParse(value);
  if (parsed == null) return 'Please enter a valid number';
  return null;
}
