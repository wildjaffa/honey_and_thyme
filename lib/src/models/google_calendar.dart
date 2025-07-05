import 'parsable.dart';

class GoogleCalendars implements Parsable {
  String? id;
  List<GoogleCalendar?>? values;

  GoogleCalendars({
    this.id,
    this.values,
  });

  GoogleCalendars.fromJson(dynamic json) {
    id = json['\$id'];
    if (json['\$values'] != null) {
      values = <GoogleCalendar>[];
      json['\$values'].forEach((v) {
        values!.add(GoogleCalendar.fromJson(v));
      });
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['\$id'] = id;
    data['\$values'] = values?.map((v) => v?.toJson()).toList();
    return data;
  }
}

class GoogleCalendar implements Parsable {
  final String id;
  final String summary;
  final String? description;
  final String? location;
  final String? timeZone;
  final bool primary;
  final bool selected;

  GoogleCalendar({
    required this.id,
    required this.summary,
    this.description,
    this.location,
    this.timeZone,
    required this.primary,
    required this.selected,
  });

  factory GoogleCalendar.fromJson(Map<String, dynamic> json) {
    return GoogleCalendar(
      id: json['id'] ?? '',
      summary: json['summary'] ?? '',
      description: json['description'],
      location: json['location'],
      timeZone: json['timeZone'],
      primary: json['primary'] ?? false,
      selected: json['selected'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'summary': summary,
      'description': description,
      'location': location,
      'timeZone': timeZone,
      'primary': primary,
      'selected': selected,
    };
  }

  GoogleCalendar copyWith({
    String? id,
    String? summary,
    String? description,
    String? location,
    String? timeZone,
    bool? primary,
    bool? selected,
  }) {
    return GoogleCalendar(
      id: id ?? this.id,
      summary: summary ?? this.summary,
      description: description ?? this.description,
      location: location ?? this.location,
      timeZone: timeZone ?? this.timeZone,
      primary: primary ?? this.primary,
      selected: selected ?? this.selected,
    );
  }
}
