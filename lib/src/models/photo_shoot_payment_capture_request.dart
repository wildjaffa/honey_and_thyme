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
    photoShootId = json['PhotoShootId'];
    externalOrderId = json['ExternalOrderId'];
    amountToBeCharged = json['AmountToBeCharged'];
    paymentProcessor = PaymentProcessors.values[json['PaymentProcessor']];
    invoiceId = json['InvoiceId'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['PhotoShootId'] = photoShootId;
    data['ExternalOrderId'] = externalOrderId;
    data['AmountToBeCharged'] = amountToBeCharged;
    data['PaymentProcessor'] = paymentProcessor?.index;
    data['InvoiceId'] = invoiceId;
    return data;
  }
}
