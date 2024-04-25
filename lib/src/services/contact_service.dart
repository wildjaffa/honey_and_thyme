import 'package:honey_and_thyme/src/models/bool_result.dart';
import 'package:honey_and_thyme/src/services/api_service.dart';

import '../models/contact_request.dart';

class ContactService {
  static Future<bool> sendContactMessage(String email, String message) async {
    try {
      final request = ContactRequest(email: email, message: message);
      ApiService.postRequest<BoolResult>(
          'api/contact', BoolResult.fromJson, request.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }
}
