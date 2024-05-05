import 'package:honey_and_thyme/src/models/booking_request.dart';
import 'package:honey_and_thyme/src/models/bool_result.dart';
import 'package:honey_and_thyme/src/services/api_service.dart';

import '../models/contact_request.dart';

class ContactService {
  static Future<bool> sendBookingRequest(BookingRequest request) async {
    try {
      final result = await ApiService.postRequest<BoolResult>(
          'api/booking', BoolResult.fromJson, request.toJson());
      return result.result ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> sendContactMessage(String email, String message) async {
    try {
      final request = ContactRequest(email: email, message: message);
      final result = await ApiService.postRequest<BoolResult>(
          'api/contact', BoolResult.fromJson, request.toJson());
      return result.result ?? false;
    } catch (e) {
      return false;
    }
  }
}
