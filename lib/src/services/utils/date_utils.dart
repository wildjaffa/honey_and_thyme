import 'package:flutter/material.dart';

extension DateTimeUtils on DateTime {
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  TimeOfDay toTimeOfDay() {
    return TimeOfDay(hour: hour, minute: minute);
  }

  DateTime setTimeOfDay(TimeOfDay timeOfDay) {
    return DateTime(
      year,
      month,
      day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
  }
}

extension TimeOfDayUtils on TimeOfDay {
  DateTime toDateTime() {
    final dateTime = DateTime.now();
    return DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      hour,
      minute,
    );
  }
}
