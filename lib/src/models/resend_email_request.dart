import 'package:honey_and_thyme/src/models/parsable.dart';

class ResendEmailRequest implements Parsable {
  final String emailRecordId;

  ResendEmailRequest({required this.emailRecordId});

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['emailRecordId'] = emailRecordId;
    return data;
  }

  ResendEmailRequest.fromJson(Map<String, dynamic> json)
      : emailRecordId = json['emailRecordId'];
}
