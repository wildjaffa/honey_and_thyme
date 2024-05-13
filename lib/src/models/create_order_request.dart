import 'package:honey_and_thyme/src/models/enums/payment_processors.dart';

class CreateOrderRequest {
  int? paymentProcessor = PaymentProcessors.paypal.index; // 0 = PayPal
  double? amount;

  CreateOrderRequest({
    this.paymentProcessor,
    this.amount,
  });

  CreateOrderRequest.fromJson(dynamic json) {
    paymentProcessor = json['PaymentProcessor'];
    amount = json['Amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['PaymentProcessor'] = paymentProcessor;
    data['Amount'] = amount;
    return data;
  }
}
