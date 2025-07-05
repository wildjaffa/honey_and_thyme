import 'package:honey_and_thyme/src/models/parsable.dart';

import 'enums/photo_shoot_status.dart';

enum PhotoShootBookStatusFilter {
  all,
  unbooked,
  booked,
}

class PhotoShootFilterRequest implements Parsable {
  DateTime? startDate;
  DateTime? endDate;
  List<PhotoShootStatus> statuses = [];
  int? pageIndex;
  int? pageSize;

  PhotoShootFilterRequest({
    this.startDate,
    this.endDate,
    this.statuses = const [],
    this.pageIndex,
    this.pageSize,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'statuses': statuses.map((status) => status.index).toList(),
      'pageIndex': pageIndex,
      'pageSize': pageSize,
    };
  }

  factory PhotoShootFilterRequest.fromJson(Map<String, dynamic> json) {
    return PhotoShootFilterRequest(
      startDate:
          json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      statuses: json['statuses']
          .map((status) => PhotoShootStatus.values.firstWhere(
                (e) => e.name == status,
              ))
          .toList(),
      pageIndex: json['pageIndex'],
      pageSize: json['pageSize'],
    );
  }
}
