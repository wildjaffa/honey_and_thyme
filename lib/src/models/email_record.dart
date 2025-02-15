import 'package:honey_and_thyme/src/models/enums/message_object_type.dart';
import 'package:honey_and_thyme/src/models/enums/message_status.dart';
import 'package:honey_and_thyme/src/models/pagination_result.dart';
import 'package:honey_and_thyme/src/models/parsable.dart';

class PaginatedEmailRecords extends PaginationResult<EmailRecord>
    implements Parsable {
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['values'] = results?.map((v) => v.toJson()).toList();
    data['pageIndex'] = pageIndex;
    data['pageSize'] = pageSize;
    data['pageCount'] = pageCount;
    data['totalCount'] = totalCount;
    return data;
  }

  PaginatedEmailRecords.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      results = <EmailRecord>[];
      json['results']['\$values'].forEach((v) {
        results!.add(EmailRecord.fromJson(v));
      });
    }
    pageIndex = json['pageIndex'];
    pageSize = json['pageSize'];
    pageCount = json['pageCount'];
    totalCount = json['totalCount'];
  }
}

class EmailRecord implements Parsable {
  String? emailRecordId;
  String? email;
  String? subject;
  String? htmlMessage;
  DateTime? dateSent;
  MessageStatus? status;
  MessageObjectType? messageObject;
  String? messageObjectId;

  EmailRecord(
      {this.emailRecordId,
      this.email,
      this.subject,
      this.htmlMessage,
      this.dateSent,
      this.status,
      this.messageObject,
      this.messageObjectId});

  EmailRecord.fromJson(dynamic json) {
    emailRecordId = json['emailRecordId'];
    email = json['email'];
    subject = json['subject'];
    htmlMessage = json['htmlMessage'];
    dateSent = DateTime.parse(json['dateSent']);
    status = MessageStatus.values[json['status']];
    messageObject = json['messageObject'] != null
        ? MessageObjectType.values[json['messageObject']]
        : null;
    messageObjectId = json['messageObjectId'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['emailRecordId'] = emailRecordId;
    data['email'] = email;
    data['subject'] = subject;
    data['htmlMessage'] = htmlMessage;
    data['dateSent'] = dateSent?.toIso8601String();
    data['status'] = status?.index;
    data['messageObject'] = messageObject?.index;
    data['messageObjectId'] = messageObjectId;
    return data;
  }
}
