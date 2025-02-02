import 'package:honey_and_thyme/src/models/parsable.dart';

import 'enums/payment_processors.dart';

class PhotoShootPaymentCaptureRequest implements Parsable {
  String? photoShootId;
  String? externalOrderId;
  double? amountToBeCharged;
  PaymentProcessors? paymentProcessor;
  String? invoiceId;

  PhotoShootPaymentCaptureRequest({
    this.photoShootId,
    this.externalOrderId,
    this.amountToBeCharged,
    this.paymentProcessor,
    this.invoiceId,
  });

  PhotoShootPaymentCaptureRequest.fromJson(Map<String, dynamic> json) {
    photoShootId = json['photoShootId'];
    externalOrderId = json['externalOrderId'];
    amountToBeCharged = json['amountToBeCharged'];
    paymentProcessor = PaymentProcessors.values[json['paymentProcessor']];
    invoiceId = json['invoiceId'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['photoShootId'] = photoShootId;
    data['externalOrderId'] = externalOrderId;
    data['amountToBeCharged'] = amountToBeCharged;
    data['paymentProcessor'] = paymentProcessor?.index;
    data['invoiceId'] = invoiceId;
    return data;
  }
}
