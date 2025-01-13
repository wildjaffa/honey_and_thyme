import 'package:honey_and_thyme/src/models/parsable.dart';

class PhotoShootFilterRequest implements Parsable {
  DateTime? startDate;
  DateTime? endDate;
  bool? excludePaidShoots;
  bool? excludeDeliveredShoots;

  PhotoShootFilterRequest({
    this.startDate,
    this.endDate,
    this.excludePaidShoots,
    this.excludeDeliveredShoots,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'excludePaidShoots': excludePaidShoots,
      'excludeDeliveredShoots': excludeDeliveredShoots,
    };
  }

  factory PhotoShootFilterRequest.fromJson(Map<String, dynamic> json) {
    return PhotoShootFilterRequest(
      startDate:
          json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      excludePaidShoots: json['excludePaidShoots'],
      excludeDeliveredShoots: json['excludeDeliveredShoots'],
    );
  }
}
