import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeButton extends StatelessWidget {
  final DateTime dateTime;
  final void Function(DateTime) onChanged;
  final DateTime lastDate;
  final DateTime firstDate;
  final String label;
  const DateTimeButton({
    super.key,
    required this.dateTime,
    required this.onChanged,
    required this.firstDate,
    required this.lastDate,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label),
        ElevatedButton(
          onPressed: () {
            showDatePicker(
              context: context,
              initialDate: dateTime.toLocal(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            ).then((value) {
              if (value != null) {
                final currentLocal = dateTime.toLocal();
                final date = DateTime(
                  value.year,
                  value.month,
                  value.day,
                  currentLocal.hour,
                  currentLocal.minute,
                );
                showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(date))
                    .then((value) {
                  if (value != null) {
                    final fullDate = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      value.hour,
                      value.minute,
                    );
                    onChanged(fullDate);
                  }
                });
              }
            });
          },
          child: Text(
            DateFormat.yMd().add_jm().format(
                  dateTime.toLocal(),
                ),
          ),
        ),
      ],
    );
  }
}
