import 'parsable.dart';

class CalendarSettings implements Parsable {
  final String? preferredCalendarId;

  CalendarSettings({
    this.preferredCalendarId,
  });

  factory CalendarSettings.fromJson(Map<String, dynamic> json) {
    return CalendarSettings(
      preferredCalendarId: json['preferredCalendarId'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'preferredCalendarId': preferredCalendarId,
    };
  }

  CalendarSettings? copyWith({String? preferredCalendarId}) {
    return CalendarSettings(
      preferredCalendarId: preferredCalendarId ?? this.preferredCalendarId,
    );
  }
}
