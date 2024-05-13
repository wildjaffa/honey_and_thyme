import 'package:honey_and_thyme/src/models/enums/payment_processors.dart';

class CaptureOrderRequest {
  int? paymentProcessor = PaymentProcessors.paypal.index;
  String? paymentProcessorTransactionId;

  CaptureOrderRequest(
      {this.paymentProcessor, this.paymentProcessorTransactionId});

  CaptureOrderRequest.fromJson(dynamic json) {
    paymentProcessor = json['PaymentProcessor'];
    paymentProcessorTransactionId = json['PaymentProcessorTransactionId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['PaymentProcessor'] = paymentProcessor;
    data['PaymentProcessorTransactionId'] = paymentProcessorTransactionId;
    return data;
  }
}
