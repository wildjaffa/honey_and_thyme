import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:honey_and_thyme/src/widgets/dollar_input_field.dart';
import 'package:honey_and_thyme/src/widgets/honey_input_field.dart';

import '../../models/product.dart';

class ProductForm extends StatelessWidget {
  static const errorStyle = TextStyle(height: 0.1, fontSize: 8);
  static final hintStyle = GoogleFonts.imFellEnglish(
    color: Colors.black,
    fontSize: 18,
  );

  final productFormKey = GlobalKey<FormState>();
  final Product product;
  final void Function() onSave;
  final void Function() onCancel;
  ProductForm({
    super.key,
    required this.product,
    required this.onSave,
    required this.onCancel,
  });

  void savePressed() {
    if (!productFormKey.currentState!.validate()) {
      return;
    }
    onSave();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: productFormKey,
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: onCancel,
                  icon: const Icon(Icons.arrow_back),
                ),
              ],
            ),
            HoneyInputField(
              initialValue: product.name,
              onChanged: (value) => product.name = value,
              label: 'Name',
            ),
            HoneyInputField(
              initialValue: product.description,
              onChanged: (value) => product.description = value,
              label: 'Description',
            ),
            DollarInputField(
              initialValue: product.price,
              onChanged: (value) => product.price = value,
              label: 'Price',
            ),
            DollarInputField(
              initialValue: product.deposit,
              onChanged: (value) => product.deposit = value,
              label: 'Deposit',
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: savePressed,
              child: const Text('Save'),
            ),
            const SizedBox(height: 10),
          ],
        ));
  }
}
