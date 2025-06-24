import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:honey_and_thyme/src/models/enums/photo_shoot_status.dart';
import 'package:honey_and_thyme/src/models/enums/photo_shoot_type.dart';
import 'package:honey_and_thyme/src/models/photo_shoot.dart';
import 'package:honey_and_thyme/src/services/photo_shoot_service.dart';
import 'package:honey_and_thyme/src/widgets/date_time_button.dart';
import 'package:honey_and_thyme/src/widgets/dollar_input_field.dart';
import 'package:honey_and_thyme/src/widgets/honey_input_field.dart';
import 'package:uuid/uuid.dart';

class NewAppointmentsForm extends StatefulWidget {
  final void Function() onSave;

  const NewAppointmentsForm({
    super.key,
    required this.onSave,
  });

  @override
  State<NewAppointmentsForm> createState() => _NewAppointmentsFormState();
}

class _NewAppointmentsFormState extends State<NewAppointmentsForm> {
  final newAppointmentsKey = GlobalKey<FormState>();
  final NewAppointmentFormData data = NewAppointmentFormData();

  Future<void> savePressed() async {
    if (!newAppointmentsKey.currentState!.validate()) {
      return;
    }
    final List<PhotoShoot> photoShoots = [];
    var appointmentStartDate = data.startDate;

    final Uuid uuid = Uuid();
    while (appointmentStartDate
            .add(data.appointmentDuration)
            .add(data.breakDuration)
            .compareTo(data.endDate) <
        1) {
      photoShoots.add(
        PhotoShoot(
          photoShootId: uuid.v4(),
          dateTimeUtc: appointmentStartDate.toUtc(),
          location: data.location,
          nameOfShoot: data.name,
          price: data.price,
          deposit: data.price,
          endDateTimeUtc:
              appointmentStartDate.add(data.appointmentDuration).toUtc(),
          description: data.description,
          photoShootType: PhotoShootType.calendarBooking,
          status: PhotoShootStatus.unbooked,
        ),
      );
      appointmentStartDate = appointmentStartDate
          .add(data.appointmentDuration)
          .add(data.breakDuration);
    }
    await PhotoShootService.createPhotoShoots(photoShoots);
    widget.onSave();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: newAppointmentsKey,
      child: Column(
        children: [
          HoneyInputField(
            initialValue: '',
            label: 'Name',
            onChanged: (value) => setState(
              () {
                data.name = value;
              },
            ),
          ),
          HoneyInputField(
            initialValue: '',
            label: 'Location',
            onChanged: (value) => setState(
              () {
                data.location = value;
              },
            ),
          ),
          DollarInputField(
            label: 'Price',
            initialValue: 0,
            onChanged: (value) => setState(() => data.price = value),
          ),
          DollarInputField(
            label: 'Deposit',
            initialValue: 0,
            onChanged: (value) => setState(() => data.deposit = value),
          ),
          DateTimeButton(
            dateTime: data.startDate,
            onChanged: (value) => setState(() {
              data.startDate = value;
            }),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            label: 'Start Date',
          ),
          DateTimeButton(
            dateTime: data.endDate,
            onChanged: (value) => setState(() {
              data.endDate = value;
            }),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            label: 'End Date',
          ),
          HoneyInputField(
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            initialValue: '15',
            label: 'Appointment Duration (minutes)',
            onChanged: (value) => setState(
              () {
                data.appointmentDuration = Duration(minutes: int.parse(value));
              },
            ),
          ),
          HoneyInputField(
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            initialValue: '5',
            label: 'Break Duration (minutes)',
            onChanged: (value) => setState(
              () {
                data.breakDuration = Duration(minutes: int.parse(value));
              },
            ),
          ),
          HoneyInputField(
            initialValue: '',
            label: 'Description',
            onChanged: (value) => setState(() => data.description = value),
          ),
          ElevatedButton(
            onPressed: savePressed,
            child: const Text('Save'),
          ),
          SizedBox(height: 100),
        ],
      ),
    );
  }
}

class NewAppointmentFormData {
  String name = '';
  DateTime startDate = DateTime.now().add(const Duration(days: 1));
  DateTime endDate =
      DateTime.now().add(const Duration(days: 1)).add(const Duration(hours: 1));
  String location = '';
  Duration appointmentDuration = const Duration(minutes: 15);
  Duration breakDuration = const Duration(minutes: 5);
  double price = 0;
  double deposit = 0;
  String description = '';
}
