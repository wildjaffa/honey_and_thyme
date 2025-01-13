import 'package:honey_and_thyme/src/models/create_photo_shoot_payment_request.dart';
import 'package:honey_and_thyme/src/models/photo_shoot.dart';
import 'package:honey_and_thyme/src/models/photo_shoot_filter_request.dart';
import 'package:honey_and_thyme/src/models/photo_shoot_payment_capture_request.dart';

import '../models/bool_result.dart';
import '../models/create_photo_shoot_payment_response.dart';
import '../models/photo_shoot_payment_capture_response.dart';
import 'api_service.dart';

class PhotoShootService {
  static Future<List<PhotoShoot>> fetchPhotoShoots(
      PhotoShootFilterRequest? filters) async {
    try {
      final result = await ApiService.postRequest<PhotoShoots>(
          'api/PhotoShoot/list', PhotoShoots.fromJson, filters?.toJson() ?? {});
      return result.values as List<PhotoShoot>;
    } catch (e) {
      return [];
    }
  }

  static Future<PhotoShoot> fetchPhotoShoot(String id) async {
    final result = await ApiService.getRequest<PhotoShoot>(
        'api/PhotoShoot/$id', PhotoShoot.fromJson);
    return result;
  }

  static Future<PhotoShoot> createPhotoShoot(PhotoShoot photoShoot) async {
    final result = await ApiService.postRequest<PhotoShoot>(
        'api/PhotoShoot/create', PhotoShoot.fromJson, photoShoot.toJson());
    return result;
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
