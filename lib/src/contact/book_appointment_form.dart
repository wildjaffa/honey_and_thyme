import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/photo_shoot.dart';
import '../widgets/honey_input_field.dart';

class BookAppointmentForm extends StatefulWidget {
  final PhotoShoot photoShoot;
  final Function(PhotoShoot) onSubmit;
  final Function(PhotoShoot) onCancel;
  const BookAppointmentForm({
    super.key,
    required this.photoShoot,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  State<BookAppointmentForm> createState() => _BookAppointmentFormState();
}

class _BookAppointmentFormState extends State<BookAppointmentForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const Text('Booking Details'),
          Text(widget.photoShoot.nameOfShoot ?? ''),
          Text(widget.photoShoot.description ?? ''),
          Text(widget.photoShoot.location ?? ''),
          Text(DateFormat('dd/MM/yyyy')
              .add_jm()
              .format(widget.photoShoot.dateTimeUtc!.toLocal())),
          Text('Price: \$${widget.photoShoot.price.toString()}'),
          Text('Deposit: \$${widget.photoShoot.deposit.toString()}'),
          const Text('Contact Details'),
          HoneyInputField(
            width: 200,
            initialValue: '',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Name is required';
              }
              return null;
            },
            label: 'Name',
            onChanged: (value) {
              widget.photoShoot.responsiblePartyName = value;
            },
          ),
          HoneyInputField(
            initialValue: '',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email is required';
              }
              return null;
            },
            label: 'Email',
            onChanged: (value) {
              widget.photoShoot.responsiblePartyEmailAddress = value;
            },
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }
                  widget.onSubmit(widget.photoShoot);
                },
                child: const Text('Submit'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  widget.onCancel(widget.photoShoot);
                },
                child: const Text('Cancel'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
