import 'dart:js_interop';

// import 'package:honey_and_thyme/src/payment/payment.dart';
// import 'package:honey_and_thyme/src/services/payment_service.dart';

@staticInterop
@JS('window')
class PayPalInterop {
  @JS()
  external static void setBaseUrl(String baseUrl);

  @JS()
  external static void setCaptureAmount(double amount);

  @JS()
  external static void renderPayPalButton(String tagName);

  // @JS('onSubmit')
  // static Future<String> createOrder() async {
  //   final order = await PaymentService.createOrder(PaymentView.paymentAmount);
  //   return order.orderId!;
  // }

  // @JS('onApprove')
  // static Future<bool> captureOrder(String orderId) async {
  //   final result = await PaymentService.captureOrder(orderId);
  //   return result.wasSuccessful!;
  // }
}
