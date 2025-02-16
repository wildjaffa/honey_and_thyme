import 'package:honey_and_thyme/src/models/email_record.dart';
import 'package:honey_and_thyme/src/models/enums/message_object_type.dart';
import 'package:honey_and_thyme/src/models/resend_email_request.dart';

import 'api_service.dart';

class EmailRecordsService {
  static Future<EmailRecord?> fetchRecord(String id) async {
    try {
      final result = await ApiService.getRequest<EmailRecord>(
          'api/emailRecords/$id', EmailRecord.fromJson);
      return result;
    } catch (e) {
      return null;
    }
  }

  static Future<PaginatedEmailRecords?> fetchRecords(int page, int pageSize,
      MessageObjectType? objectType, String? messageObjectId) async {
    try {
      var queryParameters = {
        'pageSize': pageSize.toString(),
        'pageIndex': page.toString(),
      };
      if (objectType != null) {
        queryParameters['objectType'] = objectType.index.toString();
      }
      if (messageObjectId != null) {
        queryParameters['messageObjectId'] = messageObjectId;
      }
      final result = await ApiService.getRequest<PaginatedEmailRecords>(
          'api/emailRecords/getRecords', PaginatedEmailRecords.fromJson,
          queryParameters: queryParameters);
      return result;
    } catch (e) {
      return null;
    }
  }

  static Future<EmailRecord> reSendEmail(String id) async {
    final resendEmailRequest = ResendEmailRequest(emailRecordId: id);
    final result = await ApiService.postRequest<EmailRecord>(
        'api/emailRecords/resend',
        EmailRecord.fromJson,
        resendEmailRequest.toJson());
    return result;
  }
}
