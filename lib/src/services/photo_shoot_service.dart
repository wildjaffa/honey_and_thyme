import 'package:honey_and_thyme/src/models/schedule_appointment_request.dart';
import 'package:honey_and_thyme/src/models/schedule_appointment_response.dart';
import 'package:honey_and_thyme/src/models/create_photo_shoot_payment_request.dart';
import 'package:honey_and_thyme/src/models/photo_shoot.dart';
import 'package:honey_and_thyme/src/models/photo_shoot_filter_request.dart';
import 'package:honey_and_thyme/src/models/photo_shoot_payment_capture_request.dart';
import 'package:uuid/uuid.dart';

import '../models/bool_result.dart';
import '../models/create_photo_shoot_payment_response.dart';
import '../models/photo_shoot_payment_capture_response.dart';
import 'api_service.dart';

class PhotoShootService {
  static Future<PaginatedPhotoShoots?> fetchPhotoShoots(
      PhotoShootFilterRequest? filters) async {
    try {
      final result = await ApiService.postRequest<PaginatedPhotoShoots>(
          'api/PhotoShoot/paginated',
          PaginatedPhotoShoots.fromJson,
          filters?.toJson() ?? {});
      return result;
    } catch (e) {
      return null;
    }
  }

  static Future<List<PhotoShoot>> fetchUpcomingAppointments(
      DateTime startDate, DateTime endDate) async {
    final queryParameters = {
      'startDate': startDate.toUtc().toIso8601String(),
      'endDate': endDate.toUtc().toIso8601String(),
    };
    final result = await ApiService.getRequest<PhotoShoots>(
        'api/PhotoShoot/upcoming-appointments', PhotoShoots.fromJson,
        queryParameters: queryParameters);
    return result.values as List<PhotoShoot>;
  }

  static Future<ScheduleAppointmentResponse> scheduleAppointment(
      ScheduleAppointmentRequest request) async {
    final result = await ApiService.postRequest<ScheduleAppointmentResponse>(
        'api/PhotoShoot/schedule-appointment',
        ScheduleAppointmentResponse.fromJson,
        request.toJson());
    return result;
  }

  static Future<PhotoShoot> fetchPhotoShootByReservationCode(
      String reservationCode) async {
    final result = await ApiService.getRequest<PhotoShoot>(
        'api/PhotoShoot/by-reservation-code/$reservationCode',
        PhotoShoot.fromJson);
    return result;
  }

  static Future<PhotoShoot> fetchPhotoShoot(String id) async {
    final result = await ApiService.getRequest<PhotoShoot>(
        'api/PhotoShoot/$id', PhotoShoot.fromJson);
    return result;
  }

  static Future<PhotoShoot> createPhotoShoot(PhotoShoot photoShoot) async {
    if (photoShoot.photoShootId == null) {
      final uuid = const Uuid();
      photoShoot.photoShootId = uuid.v4();
    }
    final result = await ApiService.postRequest<PhotoShoot>(
        'api/PhotoShoot/create', PhotoShoot.fromJson, photoShoot.toJson());
    return result;
  }

  static Future<List<PhotoShoot>> createPhotoShoots(
      List<PhotoShoot> photoShoots) async {
    for (final photoShoot in photoShoots) {
      if (photoShoot.photoShootId == null) {
        final uuid = const Uuid();
        photoShoot.photoShootId = uuid.v4();
      }
    }
    final result = await ApiService.postRequest<PhotoShoots>(
        'api/PhotoShoot/create-many',
        PhotoShoots.fromJson,
        photoShoots.map((e) => e.toJson()).toList());
    return result.values as List<PhotoShoot>;
  }

  static Future<PhotoShoot> updatePhotoShoot(PhotoShoot photoShoot) async {
    final result = await ApiService.postRequest<PhotoShoot>(
        'api/PhotoShoot/update', PhotoShoot.fromJson, photoShoot.toJson());
    return result;
  }

  static Future<void> deletePhotoShoot(String id) async {
    await ApiService.deleteRequest('api/PhotoShoot/$id', BoolResult.fromJson);
  }

  static Future<CreatePhotoShootPaymentResponse> createPhotoShootPayment(
      CreatePhotoShootPaymentRequest request) async {
    final result =
        await ApiService.postRequest<CreatePhotoShootPaymentResponse>(
            'api/PhotoShoot/createPayment',
            CreatePhotoShootPaymentResponse.fromJson,
            request.toJson());
    return result;
  }

  static Future<PhotoShootPaymentCaptureResponse> capturePhotoShootPayment(
      PhotoShootPaymentCaptureRequest request) async {
    final result =
        await ApiService.postRequest<PhotoShootPaymentCaptureResponse>(
            'api/PhotoShoot/capturePayment',
            PhotoShootPaymentCaptureResponse.fromJson,
            request.toJson());
    return result;
  }
}
