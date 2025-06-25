import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:honey_and_thyme/src/models/enums/photo_shoot_status.dart';
import 'package:honey_and_thyme/src/widgets/dollar_input_field.dart';
import 'package:honey_and_thyme/src/widgets/honey_input_field.dart';
import 'package:honey_and_thyme/utils/snackbar_utils.dart';
import 'package:intl/intl.dart';
import 'package:honey_and_thyme/src/models/photo_shoot.dart';

import '../../models/product.dart';
import '../../widgets/album_dropdown_search.dart';

class PhotoShootForm extends StatefulWidget {
  final PhotoShoot photoShoot;
  final void Function() onCancel;
  final void Function() onSave;
  final void Function() onMarkPaid;
  final void Function() onDelete;
  final List<Product> products;
  const PhotoShootForm({
    super.key,
    required this.photoShoot,
    required this.onCancel,
    required this.onSave,
    required this.products,
    required this.onMarkPaid,
    required this.onDelete,
  });

  @override
  State<PhotoShootForm> createState() => _PhotoShootFormState();
}

class _PhotoShootFormState extends State<PhotoShootForm> {
  final photoShootFormKey = GlobalKey<FormState>();
  bool showAdditionalFields = false;

  Product? product;

  void copyShareData() {
    final url =
        '${Uri.base.origin}/#/invoice?id=${widget.photoShoot.photoShootId}';
    var text = 'You can pay for your upcoming photo shoot at $url';

    Clipboard.setData(ClipboardData(text: text));
    showSuccess(context, 'Album linked saved to clipboard');
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Form(
        key: photoShootFormKey,
        child: ListView(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: widget.onCancel,
                  icon: const Icon(Icons.arrow_back),
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            HoneyInputField(
              initialValue: widget.photoShoot.responsiblePartyName,
              label: 'Client Name',
              onChanged: (value) =>
                  widget.photoShoot.responsiblePartyName = value,
            ),
            HoneyInputField(
              initialValue: widget.photoShoot.responsiblePartyEmailAddress,
              label: 'Client Email',
              onChanged: (value) =>
                  widget.photoShoot.responsiblePartyEmailAddress = value,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                showDatePicker(
                  context: context,
                  initialDate: widget.photoShoot.dateTimeUtc!.toLocal(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                ).then((value) {
                  if (value != null) {
                    final currentLocal =
                        widget.photoShoot.dateTimeUtc!.toLocal();
                    final date = DateTime(
                      value.year,
                      value.month,
                      value.day,
                      currentLocal.hour,
                      currentLocal.minute,
                    );
                    widget.photoShoot.dateTimeUtc = date.toUtc();
                    showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(date))
                        .then((value) {
                      if (value != null) {
                        final time = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          value.hour,
                          value.minute,
                        );
                        widget.photoShoot.dateTimeUtc = time.toUtc();
                        setState(() {});
                      }
                    });
                  }
                });
              },
              child: Text(
                DateFormat.yMd().add_jm().format(
                      widget.photoShoot.dateTimeUtc!.toLocal(),
                    ),
              ),
            ),
            const Text('Album'),
            AlbumDropdownSearch(
              onAlbumSelected: (album) {
                setState(() {
                  widget.photoShoot.albumId = album?.albumId;
                });
              },
            ),
            DropdownButton<PhotoShootStatus>(
              value: widget.photoShoot.status,
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  widget.photoShoot.status = value;
                });
              },
              items: PhotoShootStatus.values
                  .map(
                    (status) => DropdownMenuItem(
                      value: status,
                      child: Text(status.name),
                    ),
                  )
                  .toList(),
            ),
            if (widget.photoShoot.photoShootId != null)
              Text(
                'Balance: \$${widget.photoShoot.paymentRemaining! < 0 ? 0 : widget.photoShoot.paymentRemaining}',
              ),
            if (widget.photoShoot.photoShootId == null) ...[
              const Text('Product'),
              DropdownButton<Product>(
                value: product,
                onChanged: (value) {
                  if (value == null) return;
                  widget.photoShoot.nameOfShoot = value.name!;
                  widget.photoShoot.price = value.price!;
                  widget.photoShoot.deposit = value.deposit!;
                  widget.photoShoot.description = value.description!;
                  setState(() {
                    product = value;
                  });
                },
                items: widget.products
                    .map(
                      (product) => DropdownMenuItem(
                        value: product,
                        child: Text(product.name!),
                      ),
                    )
                    .toList(),
              ),
            ],
            IconButton(
              icon: Icon(showAdditionalFields ? Icons.minimize : Icons.add),
              onPressed: () {
                setState(() {
                  showAdditionalFields = !showAdditionalFields;
                });
              },
            ),
            if (showAdditionalFields) ...[
              HoneyInputField(
                initialValue: widget.photoShoot.nameOfShoot,
                label: 'Name of Shoot',
                onChanged: (value) => widget.photoShoot.nameOfShoot = value,
                validator: (p0) {
                  if (p0 == null || p0.isEmpty) {
                    return 'Name of Shoot is required';
                  }
                  return null;
                },
              ),
              HoneyInputField(
                initialValue: widget.photoShoot.description,
                label: 'Description',
                onChanged: (value) => widget.photoShoot.description = value,
              ),
              DollarInputField(
                initialValue: widget.photoShoot.price,
                label: 'Price',
                onChanged: (value) => widget.photoShoot.price = value,
              ),
              DollarInputField(
                initialValue: widget.photoShoot.deposit,
                label: 'Deposit',
                onChanged: (value) => widget.photoShoot.deposit = value,
              ),
              DollarInputField(
                initialValue: widget.photoShoot.discount,
                label: 'Discount',
                onChanged: (value) => widget.photoShoot.discount = value,
              ),
              HoneyInputField(
                initialValue: widget.photoShoot.discountName,
                label: 'Discount Name',
                onChanged: (value) => widget.photoShoot.discountName = value,
              ),
            ],
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (photoShootFormKey.currentState!.validate() &&
                    widget.photoShoot.nameOfShoot != null) {
                  widget.onSave();
                } else {
                  showError(context, 'Please fill out all required fields');
                }
              },
              child: const Text('Save'),
            ),
            if (widget.photoShoot.photoShootId != null) ...[
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: copyShareData,
                child: const Text('Copy Link to Invoice'),
              ),
            ],
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: widget.onDelete,
              child: const Text('Cancel'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: widget.onMarkPaid,
              child: const Text('Mark as Paid'),
            ),
          ],
        ),
      ),
    );
  }
}
