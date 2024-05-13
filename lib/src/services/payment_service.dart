import 'package:honey_and_thyme/src/models/capture_order_request.dart';
import 'package:honey_and_thyme/src/models/capture_order_response.dart';

import '../models/create_order_request.dart';
import '../models/create_order_response.dart';
import '../models/enums/payment_processors.dart';
import 'api_service.dart';

class PaymentService {
  static Future<CreateOrderResponse> createOrder(double amount) {
    return ApiService.postRequest<CreateOrderResponse>(
      'api/payment/createOrder',
      CreateOrderResponse.fromJson,
      CreateOrderRequest(
              paymentProcessor: PaymentProcessors.paypal.index, amount: amount)
          .toJson(),
    );
  }

  static Future<CaptureOrderResponse> captureOrder(
      String paymentProcessorTransactionId) async {
    return await ApiService.postRequest<CaptureOrderResponse>(
      'api/payment/captureOrder',
      CaptureOrderResponse.fromJson,
      CaptureOrderRequest(
              paymentProcessor: PaymentProcessors.paypal.index,
              paymentProcessorTransactionId: paymentProcessorTransactionId)
          .toJson(),
    );
  }
}
